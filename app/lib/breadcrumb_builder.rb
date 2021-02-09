class BreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder

  def render
    @elements.collect { |e| render_element(e) }.join
  end

  def render_element(element)
    @context.content_tag(:li, render_link_or_text(element), class: "govuk-breadcrumbs__list-item")
  end

  def render_link_or_text(element)
    return compute_name(element) if element.path.nil?

    @context.link_to_unless_current(
      compute_name(element), 
      compute_path(element), 
      class: "govuk-breadcrumbs__link"
    )
  end
end