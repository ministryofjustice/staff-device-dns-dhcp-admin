class ReservationsController < ApplicationController
  before_action :set_subnet
  before_action :set_reservation, only: [:edit, :update, :destroy]

  def new
    @reservation = @subnet.reservations.build
    authorize! :create, @reservation
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
end
