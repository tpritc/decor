module Admin
  class OwnersController < BaseController
    before_action :set_owner, only: %i[edit update destroy send_password_reset]

    def index
      @owners = Owner.order(:user_name)
    end

    def edit
    end

    def update
      if @owner == current_owner && !ActiveModel::Type::Boolean.new.cast(owner_params[:admin])
        redirect_to edit_admin_owner_path(@owner), alert: "You cannot remove your own admin privileges."
      elsif @owner.update(owner_params)
        redirect_to admin_owners_path, notice: "#{@owner.user_name} has been updated."
      else
        render :edit, status: :unprocessable_entity
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
