module ApplicationHelper
  def visible_field(owner, field)
    visibility = owner.send("#{field}_visibility")

    visible = case visibility
    when "public" then true
    when "members_only" then logged_in?
    when "private" then current_owner == owner
    else false
    end

    return nil unless visible

    if block_given?
      yield
    else
      owner.send(field)
    end
  end
end
