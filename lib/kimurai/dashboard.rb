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
      string :status
      datetime :start_time, empty: false
      datetime :stop_time
      string :environment
      integer :concurrent_jobs
      text :spiders
      text :error
    end

    DB.create_table?(:runs) do
      primary_key :id
      string :spider_name, empty: false
      string :status
      string :environment
      datetime :start_time, empty: false
      datetime :stop_time
      float :running_time
      foreign_key :session_id, :sessions
      foreign_key :spider_id, :spiders
      text :visits
      text :items
      text :events
      text :error
      text :server
    end

    DB.create_table?(:spiders) do
      primary_key :id
      string :name, empty: false, unique: true
    end
  end
end

require_relative 'dashboard/models/session'
require_relative 'dashboard/models/run'
require_relative 'dashboard/models/spider'
