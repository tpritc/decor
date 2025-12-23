require "test_helper"

class PasswordResetMailerTest < ActionMailer::TestCase
  def setup
    @owner = owners(:one)
    @owner.generate_password_reset_token!
  end

  test "reset_email sends to correct recipient" do
    email = PasswordResetMailer.reset_email(@owner)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@owner.email], email.to
  end

  test "reset_email has correct subject" do
    email = PasswordResetMailer.reset_email(@owner)
    assert_equal "Reset your password", email.subject
  end

  test "reset_email includes owner username in body" do
    email = PasswordResetMailer.reset_email(@owner)
    assert_match @owner.user_name, email.body.encoded
  end

  test "reset_email includes reset URL in body" do
    email = PasswordResetMailer.reset_email(@owner)
    assert_match @owner.reset_password_token, email.body.encoded
    assert_match "password_resets", email.body.encoded
  end

  test "reset_email includes expiry information" do
    email = PasswordResetMailer.reset_email(@owner)
    assert_match "2 hours", email.body.encoded
  end

  test "invite_email sends to correct recipient" do
    email = PasswordResetMailer.invite_email(@owner)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@owner.email], email.to
  end

  test "invite_email has correct subject" do
    email = PasswordResetMailer.invite_email(@owner)
    assert_equal "Welcome to DEC Owner's Registry", email.subject
  end

  test "invite_email includes owner username in body" do
    email = PasswordResetMailer.invite_email(@owner)
    assert_match @owner.user_name, email.body.encoded
  end

  test "invite_email includes setup URL in body" do
    email = PasswordResetMailer.invite_email(@owner)
    assert_match @owner.reset_password_token, email.body.encoded
    assert_match "password_resets", email.body.encoded
  end

  test "invite_email includes welcome message" do
    email = PasswordResetMailer.invite_email(@owner)
    assert_match "account has been created", email.body.encoded
    assert_match "Welcome aboard", email.body.encoded
  end
end
