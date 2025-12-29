module OwnersHelper
  def owner_filter_country_options
    visibility_values = Current.owner.present? ? %w[public members_only] : %w[public]

    Owner.where(country_visibility: visibility_values)
         .where.not(country: [nil, ""])
         .distinct
         .pluck(:country)
         .map { |code| [ISO3166::Country[code]&.common_name || ISO3166::Country[code]&.name, code] }
         .compact
         .sort_by(&:first)
  end

  def owner_filter_country_selected
    params[:country]
  end
end
