module UseCases
  module KeaConfig
    class GenerateOptionDataConfig
      def call(option)
        return {} unless option.present?

        result = {
          "option-data": []
        }

        if option.respond_to?(:domain_name) && option.domain_name.present?
          result[:"option-data"] << {
            name: "domain-name",
            data: option.domain_name
          }
        end

        if option.respond_to?(:domain_name_servers) && option.domain_name_servers.present?
          result[:"option-data"] << {
            name: "domain-name-servers",
            data: option.domain_name_servers.join(", ")
          }
        end

        if option.respond_to?(:routers) && option.routers.any?
          result[:"option-data"] << {
            name: "routers",
            data: option.routers.join(", ")
          }
        end

        if option.respond_to?(:site) && option.site.windows_update_delivery_optimisation_enabled?
          result[:"option-data"] << {
            name: "delivery-optimisation",
            space: "dhcp4",
            code: 234,
            data: option.site.uuid
          }
        end

        result
      end
    end
  end
end
