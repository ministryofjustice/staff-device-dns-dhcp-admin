class GlobalOptionPresenter < BasePresenter
  def display_name
    nil
  end

  def display_valid_lifetime
    return if record.valid_lifetime.blank?

    record.valid_lifetime > 1 ? record.valid_lifetime_unit&.downcase : record.valid_lifetime_unit&.downcase&.delete_suffix("s")
  end
end
