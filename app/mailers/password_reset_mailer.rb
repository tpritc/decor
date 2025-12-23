class PasswordResetMailer < ApplicationMailer
  def reset_email(owner)
    @owner = owner
    @reset_url = edit_password_reset_url(owner.reset_password_token)

    mail(
      to: owner.email,
      subject: "Reset your password"
    )
  end

  def invite_email(owner)
    @owner = owner
    @setup_url = edit_password_reset_url(owner.reset_password_token)

    mail(
      to: owner.email,
      subject: "Welcome to DEC Owner's Registry"
    )
  end
end
