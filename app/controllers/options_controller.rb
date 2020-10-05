class OptionsController < ApplicationController
  def new
    @option = Option.new
    authorize! :create, @option
  end
end
