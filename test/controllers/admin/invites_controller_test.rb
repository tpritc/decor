require "test_helper"

module Admin
  class InvitesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = owners(:one)
    end

    def log_in_as(owner, password: "password123")
      post session_url, params: { user_name: owner.user_name, password: password }
      follow_redirect!
    end

    # Index
    test "index displays pending invites" do
      log_in_as(@admin)
      Invite.create!(email: "pending@example.com")

      get admin_invites_url

      assert_response :success
      assert_select "h1", "Pending Invites"
    end

    test "index hides accepted invites" do
      log_in_as(@admin)
      pending = Invite.create!(email: "pending@example.com")
      accepted = Invite.create!(email: "accepted@example.com")
      accepted.accept!

      get admin_invites_url

      assert_select "td", pending.email
      assert_select "td", text: accepted.email, count: 0
    end

    # Invite creation flow
    test "new displays invite form" do
      log_in_as(@admin)
      get new_admin_invite_url

      assert_response :success
      assert_select "h1", "Invite Owner"
      assert_select "input[type=email]"
    end

    test "create sends invitation email" do
      log_in_as(@admin)
      assert_difference "Invite.count", 1 do
        perform_enqueued_jobs do
          post admin_invites_url, params: {
            invite: {
              email: "newowner@example.com"
            }
          }
        end
      end

      assert_redirected_to admin_invites_path
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
        post admin_invites_url, params: {
          invite: {
            email: "invalid-email"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_select ".text-red-700"
      assert_equal initial_delivery_count, ActionMailer::Base.deliveries.size
    end

    test "create fails with duplicate pending invite" do
      log_in_as(@admin)
      Invite.create!(email: "duplicate@example.com")

      assert_no_difference "Invite.count" do
        post admin_invites_url, params: {
          invite: {
            email: "duplicate@example.com"
          }
        }
      end

      assert_response :unprocessable_entity
      assert_select ".text-red-700"
    end

    test "create allows new invite after previous was accepted" do
      log_in_as(@admin)
      first_invite = Invite.create!(email: "reusable@example.com")
      first_invite.accept!

      assert_difference "Invite.count", 1 do
        post admin_invites_url, params: {
          invite: {
            email: "reusable@example.com"
          }
        }
      end

      assert_redirected_to admin_invites_path
    end

    test "destroy deletes invite" do
      log_in_as(@admin)
      invite = Invite.create!(email: "deleteme@example.com")

      assert_difference "Invite.count", -1 do
        delete admin_invite_url(invite)
      end

      assert_redirected_to admin_invites_path
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

    # Authorization tests
    test "non-admin cannot access index" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get admin_invites_url

      assert_redirected_to root_path
    end

    test "non-admin cannot access new invite page" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get new_admin_invite_url

      assert_redirected_to root_path
    end

    test "non-admin cannot create invite" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      assert_no_difference "Invite.count" do
        post admin_invites_url, params: {
          invite: {
            email: "test@example.com"
          }
        }
      end

      assert_redirected_to root_path
    end

    test "non-admin cannot delete invite" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")
      invite = Invite.create!(email: "delete-blocked@example.com")

      assert_no_difference "Invite.count" do
        delete admin_invite_url(invite)
      end

      assert_redirected_to root_path
    end
  end
end
