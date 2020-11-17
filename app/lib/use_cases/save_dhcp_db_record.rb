module UseCases
  class SaveDhcpDbRecord
    def initialize(generate_kea_config:, publish_kea_config:, deploy_dhcp_service:)
      @generate_kea_config = generate_kea_config
      @publish_kea_config = publish_kea_config
      @deploy_dhcp_service = deploy_dhcp_service
    end

    def call(record)
      if record.save
        kea_config = generate_kea_config.call
        publish_kea_config.call(kea_config)
        deploy_dhcp_service.call
        true
      else
        false
      end
    end

    private

    attr_reader :generate_kea_config,
      :publish_kea_config,
      :deploy_dhcp_service
  end
end
