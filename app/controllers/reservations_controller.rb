class ReservationsController < ApplicationController
  before_action :set_subnet, except: [:show, :edit, :update, :destroy]
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

  def new
    @reservation = @subnet.reservations.build
    authorize! :create, @reservation
  end

  def create
    @reservation = @subnet.reservations.build(reservation_params)
    authorize! :create, @reservation
    @result = update_dhcp_config.call(@reservation, -> { @reservation.save! })

    if @result.success?
      redirect_to subnet_path(@reservation.subnet), notice: "Successfully created reservation." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def show
    @navigation_crumbs = [["Home", root_path], ["DHCP", dhcp_path], ["Site", @reservation.subnet.site], ["Subnet", @reservation.subnet]]
  end

  def edit
    authorize! :update, @reservation
  end

  def update
    authorize! :update, @reservation
    @reservation.assign_attributes(reservation_params)
    @result = update_dhcp_config.call(@reservation, -> { @reservation.save! })

    if @result.success?
      redirect_to subnet_path(@reservation.subnet), notice: "Successfully updated reservation." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @reservation
    if confirmed?
      if update_dhcp_config.call(@reservation, -> { @reservation.destroy }).success?
        redirect_to subnet_path(@reservation.subnet), notice: "Successfully deleted reservation." + CONFIG_UPDATE_DELAY_NOTICE
      else
        redirect_to subnet_path(@reservation.subnet), error: "Failed to delete the reservation"
      end
    else
      render "destroy"
    end
  end

  private

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def set_reservation
    @reservation = Reservation.find(reservation_id)
  end

  def subnet_id
    params.fetch(:subnet_id)
  end

  def reservation_id
    params.fetch(:id)
  end

  def reservation_params
    params.require(:reservation).permit(:hw_address, :ip_address, :hostname, :description)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
