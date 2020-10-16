class SubnetPresenter < BasePresenter
  def display_name
    record.cidr_block
  end
end
