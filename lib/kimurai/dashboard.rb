require 'sequel'
require 'json'
require 'kimurai/dashboard/version'

require_relative 'dashboard/base'
require_relative 'dashboard/runner'

module Kimurai
  module Dashboard
    DB = Sequel.connect(Kimurai.configuration.stats_database_url ||= ENV["STATS_DATABASE_URL"])

    DB.create_table?(:sessions) do
      primary_key :id, type: :integer, auto_increment: false
      String :status
      Time :start_time, empty: false
      Time :stop_time
      String :environment
      Integer :concurrent_jobs
      String :spiders, text: true
      String :error, text: true
    end

    DB.create_table?(:spiders) do
      primary_key :id
      String :name, empty: false, unique: true
    end

    DB.create_table?(:runs) do
      primary_key :id
      String :spider_name, empty: false
      String :status
      String :environment
      Time :start_time, empty: false
      Time :stop_time
      Float :running_time
      foreign_key :session_id, :sessions
      foreign_key :spider_id, :spiders
      String :visits, text: true
      String :items, text: true
      String :events, text: true
      String :error, text: true
      String :server, text: true
    end
  end
end

require_relative 'dashboard/models/session'
require_relative 'dashboard/models/run'
require_relative 'dashboard/models/spider'
