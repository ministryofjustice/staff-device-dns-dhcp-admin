class ReservationOptionsController < ApplicationController
  before_action :set_reservation
  before_action :set_reservation_option

  def new
    @reservation_option = @reservation.build_reservation_option
    authorize! :create, @reservation_option
  end

  def create
    @reservation_option = @reservation.build_reservation_option(reservation_option_params)
    authorize! :create, @reservation_option
    if @reservation_option.save
      # publish_kea_config
      # deploy_dhcp_service
      redirect_to reservation_path(@reservation), notice: "Successfully created reservation options"
    else
      render :new
    end
  end

  private

  def reservation_id
    params.fetch(:reservation_id)
  end

  def set_reservation
    @reservation = Reservation.find(reservation_id)
  end

  def set_reservation_option
    @reservation_option = @reservation.reservation_option
  end

  def reservation_option_params
    params.require(:reservation_option).permit(:routers, :domain_name)
  end
end
