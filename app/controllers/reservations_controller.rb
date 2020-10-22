class ReservationsController < ApplicationController
  before_action :set_subnet
  before_action :set_reservation, only: [:show, :edit, :update, :destroy]

  def new
    @reservation = @subnet.reservations.build
    authorize! :create, @reservation
  end

  def create
    @reservation = @subnet.reservations.build(reservation_params)
    authorize! :create, @reservation
    if @reservation.save
      #publish_kea_config
      #deploy_dhcp_service
      redirect_to subnet_path(@reservation.subnet), notice: "Successfully created reservation"
    else
      render :new
    end
  end

  private

  def set_subnet
    @subnet = Subnet.find(subnet_id)
  end

  def set_reservation
    @reservation = @subnet.reservation
  end

  def subnet_id
    params.fetch(:subnet_id)
  end

  def reservation_params
    params.require(:reservation).permit(:hw_address, :ip_address, :hostname, :description)
  end

end
