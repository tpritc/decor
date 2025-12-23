module Admin
  class OwnersController < ApplicationController
    before_action :require_admin
    before_action :set_owner, only: %i[destroy send_password_reset]

    def index
      @owners = Owner.order(:user_name)
    end

    def new
      @owner = Owner.new
    end

    def create
      @owner = Owner.new(owner_params)
      @owner.password = SecureRandom.hex(32) # Temporary password, will be reset

      if @owner.save
        @owner.generate_password_reset_token!
        PasswordResetMailer.invite_email(@owner).deliver_later
        redirect_to admin_owners_path, notice: "Owner created. Invitation email has been sent."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      if @owner == current_owner
        redirect_to admin_owners_path, alert: "You cannot delete yourself."
      else
        @owner.destroy
        redirect_to admin_owners_path, notice: "Owner was successfully deleted."
      end
    end

    def send_password_reset
      @owner.generate_password_reset_token!
      PasswordResetMailer.reset_email(@owner).deliver_later
      redirect_to admin_owners_path, notice: "Password reset email has been sent to #{@owner.email}."
    end

    private

    def set_owner
      @owner = Owner.find(params[:id])
    end

    def owner_params
      params.require(:owner).permit(:user_name, :email, :admin)
    end
  end
end
