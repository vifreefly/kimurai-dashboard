module Kimurai::Dashboard
  class Session < Sequel::Model(DB)
    one_to_many :runs

    plugin :json_serializer
    plugin :serialization
    plugin :serialization_modification_detection
    serialize_attributes :json, :spiders

    unrestrict_primary_key

    def total_time
      (stop_time ? stop_time - start_time : Time.now - start_time).round(3)
    end

    def processing?
      status == "processing"
    end

    def spiders_in_queue
      return [] unless processing?
      spiders - runs_dataset.select_map(:spider_name)
    end

    def running_runs
      runs_dataset.where(status: "running").all
    end

    def failed_runs
      runs_dataset.where(status: "failed").all
    end

    def completed_runs
      runs_dataset.where(status: "completed").all
    end
  end
end
