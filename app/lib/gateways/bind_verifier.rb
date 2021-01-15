require 'tempfile'

module Gateways
  class BindVerifier
    def initialize(logger: nil)
      @logger = logger
    end

    def verify_config(config)
      file = Tempfile.new("named.conf")
      begin
        file.write(config)
        file.rewind
        handle_result(`named-checkconf #{file.path}`)
      ensure
        file.close
        file.unlink
      end
    end

    def handle_result(result)
      unless result.empty?
        logger&.info("BIND result: #{result}")
        raise InternalError.new(result)
      else
        "success"
      end
    end

    class InternalError < StandardError; end
  end
end