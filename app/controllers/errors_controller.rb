class ErrorsController < ApplicationController

  skip_before_action :authenticate_user!

  def not_found
    render status: :not_found
  end
 
  def server_error
    render status: :server_error
  end
end
