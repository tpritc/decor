module StyleHelper
  def field_classes
    "block w-full h-10 p-3 rounded border border-stone-300 bg-white text-sm focus:border-stone-500 focus:outline-none"
  end

  def button_classes(style: :secondary)
    token_list(
      "flex items-center justify-center gap-2 h-8 px-3 rounded text-sm font-medium text-center",
      "bg-decor text-white hover:bg-decor-darker focus:bg-decor-darker": style == :primary,
      "bg-stone-200 text-stone-700 hover:bg-stone-300 focus:bg-stone-300": style == :secondary
    )
  end
end
