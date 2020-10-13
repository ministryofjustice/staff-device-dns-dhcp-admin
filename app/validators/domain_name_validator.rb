class DomainNameValidator < ActiveModel::EachValidator
  DOMAIN_NAME_REGEX = /\A[a-zA-Z\d\-]+(\.[a-zA-Z\d\-]+)*\.[a-z]+\z/

  def validate_each(record, attribute, value)
    unless DOMAIN_NAME_REGEX.match?(value)
      record.errors.add(attribute, "is not valid")
    end
  end
end
