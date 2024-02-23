class SearchController < ApplicationController
  before_action :set_site, only: [:show, :edit, :update, :destroy]

  def index
    @hw_addresses = if params[:query].present?
              Reservation.where("hw_address LIKE ?",
              "%#{params[:query]}%")
             else
               Reservation.all
             end
  end


end
