class OwnersController < ApplicationController
  before_action :set_owner, only: %i[show edit update]
  before_action -> { require_owner(@owner) }, only: %i[edit update]

  def index
    @owners = Owner.all.order(:user_name)
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

  def owner_params
    params.require(:owner).permit(
      :user_name, :real_name, :email, :country, :website,
      :real_name_visibility, :email_visibility, :country_visibility
    )
  end
end
