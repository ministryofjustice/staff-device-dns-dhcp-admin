class GlobalOptionsController < ApplicationController
  before_action :set_global_option, only: [:edit, :update, :destroy]

  def index
    @global_option = GlobalOption.first
  end

  def new
    @global_option = GlobalOption.new
    authorize! :create, @global_option
  end

  def create
    @global_option = GlobalOption.new(global_option_params)
    authorize! :create, @global_option
    if @global_option.save
      redirect_to global_options_path, notice: "Successfully created global options"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @global_option
  end

  def update
    authorize! :update, @global_option
    if @global_option.update(global_option_params)
      redirect_to global_options_path, notice: "Successfully updated global options"
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @global_option
    if confirmed?
      if @global_option.destroy
        redirect_to global_options_path, notice: "Successfully deleted global options"
      else
        redirect_to global_options_path, error: "Failed to delete the global options"
      end
    end
  end

  private

  def set_global_option
    @global_option = GlobalOption.find(params.fetch(:id))
  end

  def global_option_params
    params.require(:global_option).permit(:routers, :domain_name_servers, :domain_name)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end