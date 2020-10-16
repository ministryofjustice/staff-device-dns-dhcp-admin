class AuditsController < ApplicationController
  def index
    @audits = Audit.order(created_at: "DESC").all
  end

  def show
    @audit = Audit.find(params[:id])
  end
end
