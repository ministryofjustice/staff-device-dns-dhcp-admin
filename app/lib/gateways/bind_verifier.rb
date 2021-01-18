require 'tempfile'
require 'fileutils'

module Gateways
  class BindVerifier
    def initialize(logger: nil)
      @logger = logger
    end

    def verify_config(config)
      raise EmptyConfigError.new("Some configuration options must be specified") if config.empty?

      write_config_file(config)
      handle_result(execute_checkconf(file.path))
    ensure
      file.unlink
    end

    private

    attr_reader :logger

    def file
      ensure_tmp_dir
      @file ||= Tempfile.new("named.conf", tmp_config_dir_path)
    end

    def write_config_file(config)
      file.write(config)
      file.rewind
    ensure 
      file.close
    end

    def handle_result(result)
      return true if result.empty?

      logger&.info("BIND result: #{result}")
      raise ConfigurationError.new(result)
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

    class ConfigurationError < StandardError; end
    class EmptyConfigError < ConfigurationError; end
  end
end