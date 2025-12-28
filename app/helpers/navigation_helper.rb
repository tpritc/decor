module NavigationHelper
  def navigation_link_to(name, path, **options)
    active_link_to(
      name,
      path,
      class: "font-medium text-stone-700 hover:text-stone-900",
      class_active: "mt-0.5 border-b-2 border-decor",
      **options
    )
  end
end