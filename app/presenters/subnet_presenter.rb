class SubnetPresenter < BasePresenter
  def display_name
    record.cidr_block
  end

  def display_valid_lifetime
    return if record.valid_lifetime.blank?

    if record.valid_lifetime > 1
      "#{record.valid_lifetime} #{record.valid_lifetime_unit&.downcase}"
    else
      "#{record.valid_lifetime} #{record.valid_lifetime_unit&.downcase&.delete_suffix("s")}"
    end
  end
end
