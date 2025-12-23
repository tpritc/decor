class InviteMailer < ApplicationMailer
  def invite_email(invite)
    @invite = invite
    @accept_url = new_owner_url(token: invite.token)

    mail(
      to: invite.email,
      subject: "You've been invited to DEC Owner's Registry"
    )
  end
end
