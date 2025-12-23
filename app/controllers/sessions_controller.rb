class SessionsController < ApplicationController
  before_action :require_logout, only: %i[new create]
  before_action :require_login, only: :destroy

  def new
  end

  def create
    owner = Owner.find_by("LOWER(user_name) = ?", params[:user_name]&.downcase)

    if owner&.authenticate(params[:password])
      log_in(owner)
      redirect_to root_path, notice: "Logged in successfully."
    else
      flash.now[:alert] = "Invalid username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "Logged out successfully."
  end
end
