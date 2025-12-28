class OwnersController < ApplicationController
  before_action :set_owner, only: %i[show edit update]
  before_action -> { require_owner(@owner) }, only: %i[edit update]
  before_action :load_invite, only: %i[new create]

  def index
    paginate Owner.order(:user_name).search(params[:query])
  end

  def new
    if @invite.nil? || @invite.expired? || @invite.accepted?
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    @owner = Owner.new(email: @invite.email)
  end

  def create
    if @invite.nil? || @invite.expired? || @invite.accepted?
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    @owner = Owner.new(create_owner_params)

    if @owner.save
      @invite.accept!
      session[:owner_id] = @owner.id
      redirect_to @owner, notice: "Welcome! Your account has been created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @computers = @owner.computers.includes(:computer_model)
    @components = @owner.components.includes(:component_type, :computer)
  end

  def edit
  end

  def update
    if @owner.update(owner_params)
      redirect_to @owner, notice: "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_owner
    @owner = Owner.find(params[:id])
  end

  def load_invite
    @invite = Invite.find_by(token: params[:token]) if params[:token].present?
  end

  def owner_params
    params.require(:owner).permit(
      :user_name, :real_name, :email, :country, :website,
      :real_name_visibility, :email_visibility, :country_visibility
    )
  end

  def create_owner_params
    params.require(:owner).permit(
      :user_name, :real_name, :email, :country, :website, :password, :password_confirmation,
      :real_name_visibility, :email_visibility, :country_visibility
    )
  end
end
