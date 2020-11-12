module UseCases
  class SaveDhcpDbRecord
    def initialize(publish_kea_config:, deploy_dhcp_service:)
      @publish_kea_config = publish_kea_config
      @deploy_dhcp_service = deploy_dhcp_service
    end

    def call(record)
      if record.save
        publish_kea_config.call
        deploy_dhcp_service.call
        true
      else
        false
      end
    end

    private

    attr_reader :publish_kea_config,
      :deploy_dhcp_service
  end
end
