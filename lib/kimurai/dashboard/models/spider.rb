module Kimurai::Dashboard
  class Spider < Sequel::Model(DB)
    one_to_many :runs
    plugin :json_serializer

    def current_session
      session = Session.find(status: "processing")
      return unless session
      session if session.spiders.include?(name)
    end

    def running?
      runs_dataset.first(status: "running") ? true : false
    end

    def current_state
      running? ? "running" : "stopped"
    end
  end
end
