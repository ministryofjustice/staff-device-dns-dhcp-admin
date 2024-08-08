class ReservationOptionsController < ApplicationController
  before_action :set_reservation, except: [:edit, :update, :destroy]
  before_action :set_reservation_option, only: [:edit, :update, :destroy]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "DHCP", :dhcp_path

  def new
    @reservation_option = @reservation.build_reservation_option
    authorize! :create, @reservation_option
    add_breadcrumb "Site #{@reservation.subnet.site.name}", @reservation.subnet.site
    add_breadcrumb "Subnet #{@reservation.subnet.cidr_block}", @reservation.subnet
    add_breadcrumb "Reservation #{@reservation.ip_address}", @reservation
  end

  def create
    @reservation_option = @reservation.build_reservation_option(reservation_option_params)
    authorize! :create, @reservation_option
    @result = update_dhcp_config.call(@reservation_option, -> { @reservation_option.save! })
    if @result.success?
      redirect_to reservation_path(@reservation), notice: "Successfully created reservation options." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :new
    end
  end

  def edit
    authorize! :update, @reservation_option
    add_breadcrumb "Site #{@reservation_option.reservation.subnet.site.name}", @reservation_option.reservation.subnet.site
    add_breadcrumb "Subnet #{@reservation_option.reservation.subnet.cidr_block}", @reservation_option.reservation.subnet
    add_breadcrumb "Reservation #{@reservation_option.reservation.ip_address}", @reservation_option.reservation
  end

  def update
    authorize! :update, @reservation_option
    @reservation_option.assign_attributes(reservation_option_params)
    @result = update_dhcp_config.call(@reservation_option, -> { @reservation_option.save! })

    if @result.success?
      redirect_to reservation_path(@reservation_option.reservation), notice: "Successfully updated reservation options." + CONFIG_UPDATE_DELAY_NOTICE
    else
      render :edit
    end
  end

  def destroy
    authorize! :destroy, @reservation_option
    add_breadcrumb "Site #{@reservation_option.reservation.subnet.site.name}", @reservation_option.reservation.subnet.site
    add_breadcrumb "Subnet #{@reservation_option.reservation.subnet.cidr_block}", @reservation_option.reservation.subnet
    add_breadcrumb "Reservation #{@reservation_option.reservation.ip_address}", @reservation_option.reservation
    if confirmed?
      if update_dhcp_config.call(@reservation_options, -> { @reservation_option.destroy }).success?
        redirect_to reservation_path(@reservation_option.reservation), notice: "Successfully deleted reservation options." + CONFIG_UPDATE_DELAY_NOTICE
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
