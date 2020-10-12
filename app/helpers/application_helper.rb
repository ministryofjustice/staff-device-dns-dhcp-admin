module ApplicationHelper
  def field_error(resource, key)
    resource&.errors&.include?(key.to_sym) ? "govuk-form-group--error" : ""
  end

  def selected_class_if_controller(controller_names)
    if [controller_names].flatten.include?(controller_name)
      return ' govuk-header__navigation-item--active'
    end
  end
end
