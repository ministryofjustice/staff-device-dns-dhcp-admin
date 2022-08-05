class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!

  def not_found
    render status: 404
  end
end
