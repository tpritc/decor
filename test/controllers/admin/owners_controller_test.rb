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

    test "index lists owners" do
      log_in_as(@admin)
      owner = owners(:two)

      get admin_owners_url

      assert_response :success
      assert_select "h1", "Manage Owners"
      assert_select "td", owner.user_name
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
    test "non-admin cannot access admin owners index" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get admin_owners_url

      assert_redirected_to root_path
    end
  end
end
