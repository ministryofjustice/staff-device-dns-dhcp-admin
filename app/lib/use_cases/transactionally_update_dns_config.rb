module UseCases
  class TransactionallyUpdateDnsConfig
    def initialize(generate_bind_config:, verify_bind_config:, publish_bind_config:, deploy_dns_service:)
      @generate_bind_config = generate_bind_config
      @verify_bind_config = verify_bind_config
      @publish_bind_config = publish_bind_config
      @deploy_dns_service = deploy_dns_service
    end

    def call(record, operation)
      ApplicationRecord.transaction do
        if operation.call
          bind_config = generate_bind_config.call
          config_verification_result = verify_bind_config.call(bind_config)
          if config_verification_result.success?
            publish_bind_config.call(bind_config)
            deploy_dns_service.call
            return true
          else
            raise BindConfigInvalidError.new(config_verification_result.error.message)
          end
        else
          return false
        end
      end
    rescue BindConfigInvalidError => error
      record.errors.add(:base, error.message)
      false
    end

    private

    attr_reader :generate_bind_config,
      :verify_bind_config,
      :publish_bind_config,
      :deploy_dns_service

    class BindConfigInvalidError < StandardError; end
  end
end
