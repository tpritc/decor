require "test_helper"

class InviteMailerTest < ActionMailer::TestCase
  def setup
    @invite = Invite.create!(email: "newuser@example.com")
  end

  test "invite_email sends to correct recipient" do
    email = InviteMailer.invite_email(@invite)
    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@invite.email], email.to
  end

  test "invite_email has correct subject" do
    email = InviteMailer.invite_email(@invite)
    assert_equal "You've been invited to DEC Owner's Registry", email.subject
  end

  test "invite_email includes invitation token in body" do
    email = InviteMailer.invite_email(@invite)
    assert_match @invite.token, email.body.encoded
  end

  test "invite_email includes accept URL in body" do
    email = InviteMailer.invite_email(@invite)
    assert_match "owners/new", email.body.encoded
    assert_match @invite.token, email.body.encoded
  end

  test "invite_email includes expiry information" do
    email = InviteMailer.invite_email(@invite)
    assert_match "30 days", email.body.encoded
  end

  test "invite_email includes welcome message" do
    email = InviteMailer.invite_email(@invite)
    assert_match "invited to join", email.body.encoded
    assert_match "Welcome", email.body.encoded
  end
end
