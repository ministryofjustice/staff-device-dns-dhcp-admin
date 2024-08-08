class ExclusionPresenter < BasePresenter
  delegate :subnet, to: :record

  def display_name
    "#{subnet.exclusions.first.start_address} - #{subnet.exclusions.first.end_address}"
  end
end
