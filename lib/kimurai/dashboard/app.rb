require 'sinatra/base'
require 'sinatra/respond_with'
require 'sinatra/json'
require 'sinatra/namespace'
require 'sinatra/reloader'
require 'sinatra/streaming'
require 'pagy'
require_relative 'helpers'

module Kimurai
  module Dashboard
    class App < Sinatra::Base
      include Pagy::Backend

      register Sinatra::RespondWith, Sinatra::Namespace
      enable :logging
      set :environment, Kimurai.env.to_sym

      if bind_address = Kimurai.configuration.dashboard&.dig(:bind_address)
        set :bind, bind_address
      end

      if port = Kimurai.configuration.dashboard&.dig(:port)
        set :port, port
      end

      configure :development do
        require 'pry'
        register Sinatra::Reloader
      end

      helpers Sinatra::Streaming
      helpers do
        include Helpers
        include Rack::Utils
        alias_method :h, :escape_html
      end

      if auth = Kimurai.configuration.dashboard&.dig(:basic_auth)
        use Rack::Auth::Basic, "Protected Area" do |username, password|
          username == auth[:username] && password == auth[:password]
        end
      end

      ###

      get "/" do
        redirect "/spiders"
      end

      namespace "/sessions" do
        get do
          @sessions = Session.reverse_order(:id)
          @pagy, @sessions = pagy(@sessions) unless @sessions.count.zero?

          respond_to do |f|
            f.html { erb :'sessions/index' }
          end
        end

        get "/:id" do
          @session = Session.find(id: params[:id].to_i)
          halt "Error, can't find session!" unless @session

          respond_to do |f|
            f.html { erb :'sessions/show' }
          end
        end
      end

      namespace "/runs" do
        get do
          @runs = Run.reverse_order(:id)

          filters = params.slice("spider_id", "session_id")
          filters.each do |filter_name, value|
            @runs = @runs.send(filter_name, value)
          end

          @pagy, @runs = pagy(@runs) unless @runs.count.zero?
          respond_to do |f|
            f.html { erb :'runs/index', locals: { filters: filters }}
          end
        end

        get "/:id" do
          @run = Run.find(id: params[:id].to_i)
          halt "Error, can't find session!" unless @run

          respond_to do |f|
            f.html { erb :'runs/show', locals: { difference: @run.difference_between_previous_run }}
          end
        end

        get "/:id/log" do
          @run = Run.find(id: params[:id].to_i)
          halt "Error, can't find run with id: #{params[:id]}" unless @run

          log_name = "./log/#{@run.spider_name}.log"
          if @run.latest? && File.exists?(log_name)
            content_type 'text/event-stream'
            headers['Content-Disposition'] = 'inline'

            File.readlines(log_name)
          else
            halt "Log file is not available for this run"
          end
        end
      end

      namespace "/spiders" do
        get do
          @spiders = Spider
          @pagy, @spiders = pagy(@spiders) unless @spiders.count.zero?

          respond_to do |f|
            f.html { erb :'spiders/index' }
          end
        end

        get "/:id_or_name" do
          find_spider
          halt "Error, can't find spider!" unless @spider

          @spider_runs = @spider.runs_dataset.reverse_order(:id)
          @pagy, @spider_runs = pagy(@spider_runs, items: 15) unless @spider_runs.count.zero?

          respond_to do |f|
            f.html { erb :'spiders/show' }
          end
        end

        get "/:id_or_name/log" do
          find_spider
          halt "Error, can't find spider!" unless @spider

          log_name = "./log/#{@spider.name}.log"
          if File.exists?(log_name)
            content_type 'text/event-stream'
            File.readlines(log_name)
          else
            halt "There is not log file for this spider yet"
          end
        end
      end

      private

      def find_spider
        @spider =
          if params[:id_or_name].match?(/^(\d)+$/)
            Spider.find(id: params[:id_or_name].to_i)
          else
            Spider.find(name: params[:id_or_name])
          end
      end

      def pagy_get_vars(collection, vars)
        {
          count: collection.count,
          page_param: "page",
          page: params["page"],
          items: vars[:items] || 25
        }
      end
    end
  end
end
