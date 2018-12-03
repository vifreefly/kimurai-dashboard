require 'kimurai/base'
require 'socket'

module Kimurai
  class Base
    class << self
      alias_method :original_crawl!, :crawl!
    end

    def self.crawl!(exception_on_fail: true)
      logger.error "Spider: already running: #{name}" and return false if running?

      spider = Dashboard::Spider.find_or_create(name: name)
      run = Dashboard::Run.new(spider_id: spider.id)

      updater = proc do |final_info|
        if final_info
          run.set(final_info)
          run.save
        elsif @run_info
          unless @run_info[:server]
            @run_info.merge!(
              session_id: ENV["SESSION_ID"]&.to_i,
              server: {
                hostname: Socket.gethostname,
                ipv4: Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }&.ip_address,
                process_pid: Process.pid
              }
            )
          end

          running_time = (Time.now - run_info[:start_time]).round(3)
          run.set(@run_info.merge!(running_time: running_time))
          run.save
        end
      end

      task = Thread.new do
        loop { sleep 0.5 and updater.call and sleep 1.5 }
      end

      final_info, error = original_crawl!(exception_on_fail: false)
      if error
        exception_on_fail ? raise(error) : [final_info, error]
      else
        final_info
      end
    ensure
      task.terminate if task
      updater.call(final_info)# if final_info
    end
  end
end
