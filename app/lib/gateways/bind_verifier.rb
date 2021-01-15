require 'tempfile'
require 'fileutils'

module Gateways
  class BindVerifier
    def initialize(logger: nil)
      @logger = logger
    end

    def verify_config(config)
      file.write(config)
      # file.rewind
      byebug
      handle_result(execute_checkconf(file.path))
    ensure
      file.close
      file.unlink
    end

    private

    attr_reader :logger

    def file
      ensure_tmp_dir
      @file ||= Tempfile.new("named.conf", tmp_config_dir_path)
    end

    def handle_result(result)
      return true if result.empty?

      logger&.info("BIND result: #{result}")
      raise InternalError.new(result)
    end

    def tmp_config_dir_path
      File.join(Rails.root, 'tmp/bind_configs')
    end

    def ensure_tmp_dir
      FileUtils.mkdir_p(tmp_config_dir_path)
    end

    def execute_checkconf(filepath)
      `named-checkconf #{filepath}`
    end

    class InternalError < StandardError; end
  end
end