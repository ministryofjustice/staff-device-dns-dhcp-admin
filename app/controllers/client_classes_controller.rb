class ClientClassesController < ApplicationController
  before_action :set_client_class, only: [:edit, :update, :destroy]
  
  def index
    @client_class = ClientClass.first
  end

  def new
    @client_class = ClientClass.new
    authorize! :create, @client_class
  end

  def create
    @client_class = ClientClass.new(client_class_params)
    authorize! :create, @client_class

    if save_dhcp_record(@client_class)
      redirect_to client_classes_path, notice: "Successfully created client class"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @client_class
  end

  def update
    authorize! :update, @client_class
    @client_class.assign_attributes(client_class_params)

    if save_dhcp_record(@client_class)
      redirect_to client_classes_path, notice: "Successfully updated client class"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @client_class
    if confirmed?
      if @client_class.destroy
        publish_kea_config
        deploy_dhcp_service
        redirect_to client_classes_path, notice: "Successfully deleted client class"
      else
        redirect_to client_classes_path, error: "Failed to delete the client class"
      end
    end
  end

  def set_client_class
    @client_class = ClientClass.find(params.fetch(:id))
  end

  def client_class_params
    params.require(:client_class).permit(:name, :client_id, :domain_name_servers, :domain_name)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end

end