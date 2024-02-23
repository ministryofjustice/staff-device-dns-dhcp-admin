class SearchController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  def index
    @hw_addresses = if params[:query].present?
              Reservation.where("hw_address LIKE ?",
              "%#{params[:query]}%").pluck("reservations.hw_address")
             else
               Reservation.all.map(&:hw_address)
             end
  end


end
