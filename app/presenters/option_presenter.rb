class OptionPresenter < BasePresenter
  delegate :subnet, to: :record

  def display_name
    subnet.cidr_block
  end
end
