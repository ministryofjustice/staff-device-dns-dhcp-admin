module ConfigurationPublishingAssertions
  def expect_config_to_be_published
    expect_any_instance_of(Gateways::S3).to receive(:write)
  end

  def expect_service_to_be_rebooted
    expect_any_instance_of(Gateways::Ecs).to receive(:update_service)
  end

  def expect_config_to_be_verified
    expect_any_instance_of(Gateways::KeaControlAgent).to receive(:verify_config)
      .and_return({ "result" => 0 })
  end
end
