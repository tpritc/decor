require "test_helper"

class OwnersControllerTest < ActionDispatch::IntegrationTest
  # Invite acceptance flow tests
  test "new displays invite acceptance form with valid token" do
    invite = Invite.create!(email: "newuser@example.com")

    get new_owner_url(token: invite.token)

    assert_response :success
    assert_select "h1", "Create Your Account"
    assert_select "input[type=email][value=?]", invite.email
  end

  test "new redirects with invalid token" do
    get new_owner_url(token: "invalid-token")

    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  test "new redirects with expired token" do
    invite = Invite.create!(email: "expired@example.com")
    invite.update_column(:sent_at, 31.days.ago)

    get new_owner_url(token: invite.token)

    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  test "new redirects with already accepted token" do
    invite = Invite.create!(email: "accepted@example.com")
    invite.accept!

    get new_owner_url(token: invite.token)

    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  test "create accepts invite and creates owner account" do
    invite = Invite.create!(email: "newowner@example.com")

    assert_difference "Owner.count", 1 do
      post owners_url(token: invite.token), params: {
        owner: {
          user_name: "newuser",
          email: invite.email,
          password: "password123",
          password_confirmation: "password123",
          real_name: "New User",
          country: "US"
        }
      }
    end

    assert_redirected_to owner_path(Owner.last)
    assert_equal "Welcome! Your account has been created.", flash[:notice]

    # Verify invite was accepted
    invite.reload
    assert invite.accepted?

    # Verify owner was created correctly
    owner = Owner.last
    assert_equal "newuser", owner.user_name
    assert_equal invite.email, owner.email
    assert_equal "New User", owner.real_name
    assert_equal "US", owner.country

    # Verify user is logged in
    assert_equal owner.id, session[:owner_id]
  end

  test "create fails with invalid owner data" do
    invite = Invite.create!(email: "newowner@example.com")

    assert_no_difference "Owner.count" do
      post owners_url(token: invite.token), params: {
        owner: {
          user_name: "", # Invalid: blank username
          email: invite.email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".text-red-800"

    # Verify invite was not accepted
    invite.reload
    assert_not invite.accepted?
  end

  test "create fails with mismatched passwords" do
    invite = Invite.create!(email: "newowner@example.com")

    assert_no_difference "Owner.count" do
      post owners_url(token: invite.token), params: {
        owner: {
          user_name: "newuser",
          email: invite.email,
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "create redirects with expired token" do
    invite = Invite.create!(email: "expired@example.com")
    invite.update_column(:sent_at, 31.days.ago)

    assert_no_difference "Owner.count" do
      post owners_url(token: invite.token), params: {
        owner: {
          user_name: "newuser",
          email: invite.email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end

  test "create redirects with already accepted token" do
    invite = Invite.create!(email: "accepted@example.com")
    invite.accept!

    assert_no_difference "Owner.count" do
      post owners_url(token: invite.token), params: {
        owner: {
          user_name: "newuser",
          email: invite.email,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Invalid or expired invitation.", flash[:alert]
  end
end
