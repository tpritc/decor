class PasswordResetsController < ApplicationController
  before_action :require_logout
  before_action :set_owner_by_token, only: %i[edit update]

  def new
  end

  def create
    owner = Owner.find_by(email: params[:email]&.downcase)

    if owner
      owner.generate_password_reset_token!
      PasswordResetMailer.reset_email(owner).deliver_later
    end

    # Always show success to prevent email enumeration
    redirect_to new_session_path, notice: "If an account exists with that email, you will receive password reset instructions."
  end

  def edit
  end

  def update
    if password_params[:password].blank?
      @owner.errors.add(:password, "can't be blank")
      render :edit, status: :unprocessable_entity
    elsif @owner.update(password_params)
      @owner.clear_password_reset_token!
      log_in(@owner)
      redirect_to root_path, notice: "Password has been reset successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_owner_by_token
    @owner = Owner.find_by(reset_password_token: params[:token])

    if @owner.nil? || @owner.password_reset_expired?
      redirect_to new_password_reset_path, alert: "Password reset link is invalid or has expired."
    end
  end

  def password_params
    params.require(:owner).permit(:password, :password_confirmation)
  end
end
