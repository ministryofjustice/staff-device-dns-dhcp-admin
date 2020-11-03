class ReservationOptionsController < ApplicationController
  before_action :set_reservation, except: [:destroy]
  before_action :set_reservation_option, only: [:destroy]

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

  def destroy
    authorize! :destroy, @reservation_option
    if confirmed?
      if @reservation_option.destroy
        # publish_kea_config
        # deploy_dhcp_service
        redirect_to reservation_path(@reservation_option.reservation), notice: "Successfully deleted reservation options"
      else
        redirect_to reservation_path(@reservation_option.reservation), error: "Failed to delete the reservation options"
      end
    else
      render "destroy"
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
    @reservation_option = ReservationOption.find(reservation_option_id)
  end

  def reservation_option_id
    params.fetch(:id)
  end

  def reservation_option_params
    params.require(:reservation_option).permit(:routers, :domain_name)
  end

  def confirmed?
    params.fetch(:confirm, false)
  end
end
