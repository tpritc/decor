module ApplicationHelper
  def visible_field(owner, field)
    visibility = owner.send("#{field}_visibility")

    visible = case visibility
    when "public" then true
    when "members_only" then logged_in?
    when "private" then Current.owner == owner
    else false
    end

    return nil unless visible

    if block_given?
      yield
    else
      owner.send(field)
    end
  end

  def empty_state(message)
    tag.div message, class: "col-span-full flex items-center justify-center min-h-32 p-4 bg-stone-100 text-stone-500 text-sm"
  end
end