require "test_helper"

module Admin
  class OwnersControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = owners(:one)
    end

    def log_in_as(owner, password: "password123")
      post session_url, params: { user_name: owner.user_name, password: password }
      follow_redirect!
    end

    # Invite creation flow
    test "new displays invite form" do
      log_in_as(@admin)
      get new_admin_owner_url

      assert_response :success
      assert_select "h1", "Invite Owner"
      assert_select "input[type=email]"
    end

    test "create sends invitation email" do
      log_in_as(@admin)
      assert_difference "Invite.count", 1 do
        perform_enqueued_jobs do
          post admin_owners_url, params: {
            invite: {
              email: "newowner@example.com"
            }
          }
        end
      end

      assert_redirected_to admin_owners_path
      assert_match /invitation sent/i, flash[:notice]

      # Verify invite was created
      invite = Invite.last
      assert_equal "newowner@example.com", invite.email
      assert_not_nil invite.token
      assert_not invite.accepted?

      # Verify email was sent
      assert_equal 1, ActionMailer::Base.deliveries.size
      email = ActionMailer::Base.deliveries.last
      assert_equal ["newowner@example.com"], email.to
    end

    test "create fails with invalid email" do
      log_in_as(@admin)
      initial_delivery_count = ActionMailer::Base.deliveries.size

      assert_no_difference "Invite.count" do
        post admin_owners_url, params: {
          invite: {
            email: "invalid-email"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_select ".text-red-700" # Error messages are shown in red-700
      assert_equal initial_delivery_count, ActionMailer::Base.deliveries.size
    end

    test "create fails with duplicate pending invite" do
      log_in_as(@admin)
      Invite.create!(email: "duplicate@example.com")

      assert_no_difference "Invite.count" do
        post admin_owners_url, params: {
          invite: {
            email: "duplicate@example.com"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_select ".text-red-700" # Error messages are shown in red-700
    end

    test "create allows new invite after previous was accepted" do
      log_in_as(@admin)
      first_invite = Invite.create!(email: "reusable@example.com")
      first_invite.accept!

      assert_difference "Invite.count", 1 do
        post admin_owners_url, params: {
          invite: {
            email: "reusable@example.com"
          }
        }
      end

      assert_redirected_to admin_owners_path
    end

    # Verify 30-day expiry for invites
    test "invite expires after 30 days" do
      invite = Invite.create!(email: "expiring@example.com")

      # Invite is valid now
      assert_not invite.expired?

      # Move time forward by 29 days (still valid)
      invite.update_column(:sent_at, 29.days.ago)
      assert_not invite.expired?

      # Move time forward by 30 days 1 minute (expired)
      invite.update_column(:sent_at, 30.days.ago - 1.minute)
      assert invite.expired?
    end

    # Password reset flow for existing owners
    test "send_password_reset sends email to owner" do
      log_in_as(@admin)
      owner = owners(:two)

      perform_enqueued_jobs do
        post send_password_reset_admin_owner_url(owner)
      end

      assert_redirected_to admin_owners_path
      assert_match /password reset email/i, flash[:notice]

      # Verify token was generated
      owner.reload
      assert_not_nil owner.reset_password_token
      assert_not_nil owner.reset_password_sent_at

      # Verify email was sent
      assert ActionMailer::Base.deliveries.size > 0
    end

    # Edit/Update admin status
    test "edit displays owner admin form" do
      log_in_as(@admin)
      other_owner = owners(:two)

      get edit_admin_owner_url(other_owner)

      assert_response :success
      assert_select "h1", /Edit Owner/
      assert_select "input[type=checkbox][name='owner[admin]']"
    end

    test "can grant admin to another owner" do
      log_in_as(@admin)
      other_owner = owners(:two)
      assert_not other_owner.admin?

      patch admin_owner_url(other_owner), params: { owner: { admin: true } }

      assert_redirected_to admin_owners_path
      other_owner.reload
      assert other_owner.admin?
    end

    test "can revoke admin from another owner" do
      log_in_as(@admin)
      other_admin = owners(:two)
      other_admin.update!(admin: true)

      patch admin_owner_url(other_admin), params: { owner: { admin: false } }

      assert_redirected_to admin_owners_path
      other_admin.reload
      assert_not other_admin.admin?
    end

    test "cannot remove own admin privileges" do
      log_in_as(@admin)

      patch admin_owner_url(@admin), params: { owner: { admin: false } }

      assert_redirected_to edit_admin_owner_path(@admin)
      assert_match /cannot remove your own admin/, flash[:alert]
      @admin.reload
      assert @admin.admin?
    end

    test "can edit own profile but admin stays true" do
      log_in_as(@admin)

      patch admin_owner_url(@admin), params: { owner: { admin: true } }

      assert_redirected_to admin_owners_path
      @admin.reload
      assert @admin.admin?
    end

    # Authorization tests
    test "non-admin cannot access new invite page" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get new_admin_owner_url

      assert_redirected_to root_path
    end

    test "non-admin cannot create invite" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      assert_no_difference "Invite.count" do
        post admin_owners_url, params: {
          invite: {
            email: "test@example.com"
          }
        }
      end

      assert_redirected_to root_path
    end
  end
end
