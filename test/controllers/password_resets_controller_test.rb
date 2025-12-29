require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = owners(:one)
  end

  # Request password reset flow
  test "new displays password reset request form" do
    get new_password_reset_url

    assert_response :success
    assert_select "h1", "Forgot Password"
    assert_select "input[type=email]"
  end

  test "create sends password reset email for existing email" do
    perform_enqueued_jobs do
      post password_resets_url, params: { email: @owner.email }
    end

    assert_redirected_to new_session_path
    assert_match /will receive password reset instructions/i, flash[:notice]

    # Verify token was generated
    @owner.reload
    assert_not_nil @owner.reset_password_token
    assert_not_nil @owner.reset_password_sent_at

    # Verify email was sent
    assert ActionMailer::Base.deliveries.size > 0
  end

  test "create shows success message for non-existent email (security)" do
    initial_delivery_count = ActionMailer::Base.deliveries.size

    post password_resets_url, params: { email: "nonexistent@example.com" }

    assert_redirected_to new_session_path
    assert_match /will receive password reset instructions/i, flash[:notice]

    # Verify no email was sent
    assert_equal initial_delivery_count, ActionMailer::Base.deliveries.size
  end

  # Edit password reset form
  test "edit displays password reset form with valid token" do
    @owner.generate_password_reset_token!

    get edit_password_reset_url(@owner.reset_password_token)

    assert_response :success
    assert_select "h1", "Reset Password"
    assert_select "input[type=password]", 2
  end

  test "edit redirects with invalid token" do
    get edit_password_reset_url("invalid-token")

    assert_redirected_to new_password_reset_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "edit redirects with expired token" do
    @owner.generate_password_reset_token!
    @owner.update_column(:reset_password_sent_at, 3.hours.ago)

    get edit_password_reset_url(@owner.reset_password_token)

    assert_redirected_to new_password_reset_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  # Update password
  test "update resets password with valid token and matching passwords" do
    @owner.generate_password_reset_token!
    old_password_digest = @owner.password_digest
    token = @owner.reset_password_token

    patch password_reset_url(token), params: {
      owner: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to root_path
    assert_equal "Password has been reset successfully.", flash[:notice]

    # Verify password was changed
    @owner.reload
    assert_not_equal old_password_digest, @owner.password_digest
    assert @owner.authenticate("newpassword123")

    # Verify token was cleared
    assert_nil @owner.reset_password_token
    assert_nil @owner.reset_password_sent_at
  end

  test "update fails with mismatched passwords" do
    @owner.generate_password_reset_token!
    token = @owner.reset_password_token
    old_password_digest = @owner.password_digest

    patch password_reset_url(token), params: {
      owner: {
        password: "newpassword123",
        password_confirmation: "different"
      }
    }

    assert_response :unprocessable_entity
    assert_record_errors

    # Verify password was not changed
    @owner.reload
    assert_equal old_password_digest, @owner.password_digest
  end

  test "update fails with invalid token" do
    patch password_reset_url("invalid-token"), params: {
      owner: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to new_password_reset_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "update fails with expired token" do
    @owner.generate_password_reset_token!
    @owner.update_column(:reset_password_sent_at, 3.hours.ago)
    token = @owner.reset_password_token

    patch password_reset_url(token), params: {
      owner: {
        password: "newpassword123",
        password_confirmation: "newpassword123"
      }
    }

    assert_redirected_to new_password_reset_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end

  test "update fails with blank password" do
    @owner.generate_password_reset_token!
    token = @owner.reset_password_token

    patch password_reset_url(token), params: {
      owner: {
        password: "",
        password_confirmation: ""
      }
    }

    assert_response :unprocessable_entity
    assert_record_errors
  end

  # Verify 2-hour expiry
  test "password reset token expires after 2 hours" do
    @owner.generate_password_reset_token!
    token = @owner.reset_password_token

    # Token is valid now
    assert_not @owner.password_reset_expired?

    # Move time forward by 1 hour 59 minutes (still valid)
    @owner.update_column(:reset_password_sent_at, 1.hour.ago - 59.minutes)
    assert_not @owner.password_reset_expired?

    # Move time forward by 2 hours 1 minute (expired)
    @owner.update_column(:reset_password_sent_at, 2.hours.ago - 1.minute)
    assert @owner.password_reset_expired?
  end
end
