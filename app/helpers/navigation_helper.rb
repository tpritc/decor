module NavigationHelper
  def navigation_link_to(name, path, **options)
    active_link_to(
      name,
      path,
      class: "mt-0.5 font-medium text-stone-700 hover:text-stone-900 border-b-2 hover:border-decor-lighter",
      class_active: "border-decor",
      class_inactive: "border-transparent",
      **options
    )
  end
end