module UseCases
  class DeployKeaConfig
    def initialize(ecs_gateway:)
      @ecs_gateway = ecs_gateway
    end

    def execute
      ecs_gateway.update_service
    end

    private

    attr_reader :ecs_gateway
  end
end
