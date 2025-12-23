module Admin
  class InvitesController < BaseController
    def index
      @invites = Invite.pending.order(sent_at: :desc)
    end

    def new
      @invite = Invite.new
    end

    def create
      @invite = Invite.new(invite_params)

      if @invite.save
        InviteMailer.invite_email(@invite).deliver_later
        redirect_to admin_invites_path, notice: "Invitation sent to #{@invite.email}."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @invite = Invite.find(params[:id])
      @invite.destroy
      redirect_to admin_invites_path, notice: "Invitation was deleted."
    end

    private

    def invite_params
      params.require(:invite).permit(:email)
    end
  end
end
