require 'kimurai/runner'

module Kimurai
  class Runner
    alias_method :original_run!, :run!
    def run!(exception_on_fail: true)
      register_session(session_info)
      _, error = original_run!(exception_on_fail: false)
      update_session(session_info)

      if error
        exception_on_fail ? raise(error) : [session_info, error]
      else
        session_info
      end
    end

    private

    def register_session(session_info)
      Dashboard::Session.create(session_info)
    end

    def update_session(session_info)
      session = Dashboard::Session.find(session_info[:id]).first
      session.set(session_info)
      session.save
    end
  end
end

