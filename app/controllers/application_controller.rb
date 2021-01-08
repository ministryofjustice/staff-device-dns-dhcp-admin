class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  after_action :set_expect_ct_header

  def new_session_path(scope)
    new_user_session_path
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404.html", status: :not_found }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to main_app.root_path, notice: exception.message }
    end
  end

  private

  def set_expect_ct_header
    response.headers["Expect-CT"] = "max-age=86400, enforce"
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end

  def deploy_dns_service
    UseCases::DeployService.new(
      ecs_gateway: Gateways::Ecs.new(
        cluster_name: ENV.fetch("DNS_CLUSTER_NAME"),
        service_name: ENV.fetch("DNS_SERVICE_NAME"),
        aws_config: Rails.application.config.ecs_aws_config
      )
    ).call
  end

  def publish_kea_config
    UseCases::PublishKeaConfig.new(
      destination_gateway: Gateways::S3.new(
        bucket: ENV.fetch("KEA_CONFIG_BUCKET"),
        key: "config.json",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "application/json"
      )
    )
  end

  def update_dhcp_config
    UseCases::TransactionallyUpdateDhcpConfig.new(
      generate_kea_config: -> { generate_kea_config.call },
      verify_kea_config: verify_kea_config,
      publish_kea_config: publish_kea_config,
    )
  end

  def generate_kea_config
    UseCases::GenerateKeaConfig.new(
      subnets: Subnet.includes(
        :site,
        :option,
        reservations: [:reservation_option]
      ).all,
      global_option: GlobalOption.first,
      client_classes: ClientClass.all
    )
  end

  def kea_control_agent_gateway
    Gateways::KeaControlAgent.new(
      uri: ENV.fetch("KEA_CONTROL_AGENT_URI"),
      logger: Rails.logger
    )
  end

  def verify_kea_config
    UseCases::VerifyKeaConfig.new(
      kea_control_agent_gateway: kea_control_agent_gateway
    )
  end
end
