class HostNameValidator < ActiveModel::EachValidator
    HOSTNAME_REGEX = /\A[\w+\.\-]+\z/

  def validate_each(record, attribute, value)
    return if value.blank?

    unless HOSTNAME_REGEX.match?(value)
      record.errors.add(attribute, "is not valid")
    end
  end
end