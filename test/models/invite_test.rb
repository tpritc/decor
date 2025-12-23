require "test_helper"

class InviteTest < ActiveSupport::TestCase
  def valid_attributes
    {
      email: "test@example.com"
    }
  end

  # Validations
  test "valid invite with required attributes" do
    invite = Invite.new(valid_attributes)
    assert invite.valid?
  end

  test "email is required" do
    invite = Invite.new(valid_attributes.merge(email: nil))
    assert_not invite.valid?
    assert_includes invite.errors[:email], "can't be blank"
  end

  test "email must be valid format" do
    invalid_emails = [ "invalid", "invalid@", "@example.com", "invalid@.com" ]
    invalid_emails.each do |email|
      invite = Invite.new(valid_attributes.merge(email: email))
      assert_not invite.valid?, "#{email} should be invalid"
    end
  end

  test "email accepts valid formats" do
    valid_emails = [ "user@example.com", "user+tag@example.com", "user@sub.example.com" ]
    valid_emails.each do |email|
      invite = Invite.new(valid_attributes.merge(email: email))
      assert invite.valid?, "#{email} should be valid: #{invite.errors.full_messages}"
    end
  end

  test "cannot create duplicate pending invite for same email" do
    Invite.create!(valid_attributes)
    duplicate = Invite.new(valid_attributes)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:email], "has already been taken"
  end

  test "can create new invite for same email after previous is accepted" do
    first_invite = Invite.create!(valid_attributes)
    first_invite.accept!

    second_invite = Invite.new(valid_attributes)
    assert second_invite.valid?
  end

  # Token generation
  test "generates token on create" do
    invite = Invite.create!(valid_attributes)
    assert_not_nil invite.token
    assert invite.token.length > 20
  end

  test "token is unique" do
    first = Invite.create!(valid_attributes)
    second = Invite.create!(email: "other@example.com")
    assert_not_equal first.token, second.token
  end

  # Timestamps
  test "sets sent_at on create" do
    invite = Invite.create!(valid_attributes)
    assert_not_nil invite.sent_at
    assert_in_delta Time.current, invite.sent_at, 1.second
  end

  # Expiry
  test "expired? returns true for old invites" do
    invite = Invite.create!(valid_attributes)
    invite.update_column(:sent_at, 31.days.ago)
    assert invite.expired?
  end

  test "expired? returns false for recent invites" do
    invite = Invite.create!(valid_attributes)
    assert_not invite.expired?
  end

  test "expired? returns false for accepted invites regardless of age" do
    invite = Invite.create!(valid_attributes)
    invite.update_column(:sent_at, 31.days.ago)
    invite.accept!
    assert_not invite.expired?
  end

  # Acceptance
  test "accepted? returns false for new invites" do
    invite = Invite.create!(valid_attributes)
    assert_not invite.accepted?
  end

  test "accepted? returns true after accept!" do
    invite = Invite.create!(valid_attributes)
    invite.accept!
    assert invite.accepted?
  end

  test "accept! sets accepted_at timestamp" do
    invite = Invite.create!(valid_attributes)
    assert_nil invite.accepted_at

    invite.accept!
    assert_not_nil invite.accepted_at
    assert_in_delta Time.current, invite.accepted_at, 1.second
  end

  # Scopes
  test "pending scope returns unaccepted invites" do
    pending = Invite.create!(email: "pending@example.com")
    accepted = Invite.create!(email: "accepted@example.com")
    accepted.accept!

    assert_includes Invite.pending, pending
    assert_not_includes Invite.pending, accepted
  end

  test "accepted scope returns accepted invites" do
    pending = Invite.create!(email: "pending@example.com")
    accepted = Invite.create!(email: "accepted@example.com")
    accepted.accept!

    assert_includes Invite.accepted, accepted
    assert_not_includes Invite.accepted, pending
  end

  test "expired scope returns old pending invites" do
    fresh = Invite.create!(email: "fresh@example.com")
    old = Invite.create!(email: "old@example.com")
    old.update_column(:sent_at, 31.days.ago)

    assert_includes Invite.expired, old
    assert_not_includes Invite.expired, fresh
  end

  test "valid_invites scope returns recent pending invites" do
    fresh = Invite.create!(email: "fresh@example.com")
    old = Invite.create!(email: "old@example.com")
    old.update_column(:sent_at, 31.days.ago)

    assert_includes Invite.valid_invites, fresh
    assert_not_includes Invite.valid_invites, old
  end
end
