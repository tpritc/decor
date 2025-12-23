module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_owner, :logged_in?, :admin?
  end

  def current_owner
    @current_owner ||= Owner.find_by(id: session[:owner_id]) if session[:owner_id]
  end

  def logged_in?
    current_owner.present?
  end

  def log_in(owner)
    session[:owner_id] = owner.id
  end

  def log_out
    session.delete(:owner_id)
    @current_owner = nil
  end

  def require_login
    unless logged_in?
      redirect_to new_session_path, alert: "Please log in to continue."
    end
  end

  def require_logout
    if logged_in?
      redirect_to root_path, alert: "You are already logged in."
    end
  end

  def require_owner(owner)
    unless current_owner == owner || admin?
      redirect_to root_path, alert: "You are not authorized to do that."
    end
  end

  def admin?
    current_owner&.admin?
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "You must be an admin to do that."
    end
  end
end
