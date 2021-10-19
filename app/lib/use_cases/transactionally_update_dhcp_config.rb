module UseCases
  class TransactionallyUpdateDhcpConfig
    def initialize(generate_kea_config:, verify_kea_config:, publish_kea_config:)
      @generate_kea_config = generate_kea_config
      @verify_kea_config = verify_kea_config
      @publish_kea_config = publish_kea_config
    end

    def call(record, operation)
      ApplicationRecord.transaction do
        if operation.call
          kea_config = generate_kea_config.call
          config_verification_result = verify_kea_config.call(kea_config)
          if config_verification_result.success?
            publish_kea_config.call(kea_config)
          else
            raise KeaConfigInvalidError.new(config_verification_result.errors.first.message)
          end
        else
          raise OperationFailedError.new
        end
      end

      Result.new
    rescue KeaConfigInvalidError => error
      Result.new(error)
    rescue OperationFailedError => error
      Result.new(error)
    end

    private

    attr_reader :generate_kea_config,
      :verify_kea_config,
      :publish_kea_config

    class KeaConfigInvalidError < StandardError; end

    class OperationFailedError < StandardError; end
  end
end
