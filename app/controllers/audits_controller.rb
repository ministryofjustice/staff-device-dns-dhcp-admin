class AuditsController < ApplicationController
  def index
    @audits = Audit.order(created_at: "DESC").all
  end
end
