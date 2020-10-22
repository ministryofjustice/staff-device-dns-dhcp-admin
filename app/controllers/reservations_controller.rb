class ReservationsController < ApplicationController
  before_action :set_subnet, except: [:edit, :update]
  before_action :set_reservation, only: [:show, :edit, :update]

  def new
    @reservation = @subnet.reservations.build
    authorize! :create, @reservation
  end

  def create
    @reservation = @subnet.reservations.build(reservation_params)
    authorize! :create, @reservation
    if @reservation.save
      # publish_kea_config
      # deploy_dhcp_service
      redirect_to subnet_path(@reservation.subnet), notice: "Successfully created reservation"
    else
      render :new
    end
  end

  def edit
    authorize! :update, @reservation
  end

  def update
    authorize! :update, @reservation
    if @reservation.update(reservation_params)
      # publish_kea_config
      # deploy_dhcp_service
      redirect_to subnet_path(@reservation.subnet), notice: "Successfully updated reservation"
    else
      render :edit
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
end