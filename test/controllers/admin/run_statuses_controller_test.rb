require "test_helper"

module Admin
  class RunStatusesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = owners(:one)
      @run_status = run_statuses(:working)
    end

    def log_in_as(owner, password: "password123")
      post session_url, params: { user_name: owner.user_name, password: password }
      follow_redirect!
    end

    # Index
    test "index displays run statuses" do
      log_in_as(@admin)

      get admin_run_statuses_url

      assert_response :success
      assert_select "h1", "Run Statuses"
      assert_select "td", @run_status.name
    end

    # New
    test "new displays form" do
      log_in_as(@admin)

      get new_admin_run_status_url

      assert_response :success
      assert_select "h1", "New Run Status"
      assert_select "input[name='run_status[name]']"
    end

    # Create
    test "create adds new run status" do
      log_in_as(@admin)

      assert_difference "RunStatus.count", 1 do
        post admin_run_statuses_url, params: {
          run_status: { name: "New Status" }
        }
      end

      assert_redirected_to admin_run_statuses_path
      assert_match /successfully created/i, flash[:notice]
    end

    test "create fails with blank name" do
      log_in_as(@admin)

      assert_no_difference "RunStatus.count" do
        post admin_run_statuses_url, params: {
          run_status: { name: "" }
        }
      end

      assert_response :unprocessable_entity
    end

    test "create fails with duplicate name" do
      log_in_as(@admin)

      assert_no_difference "RunStatus.count" do
        post admin_run_statuses_url, params: {
          run_status: { name: @run_status.name }
        }
      end

      assert_response :unprocessable_entity
    end

    # Edit
    test "edit displays form" do
      log_in_as(@admin)

      get edit_admin_run_status_url(@run_status)

      assert_response :success
      assert_select "h1", "Edit Run Status"
      assert_select "input[value='#{@run_status.name}']"
    end

    # Update
    test "update changes run status" do
      log_in_as(@admin)

      patch admin_run_status_url(@run_status), params: {
        run_status: { name: "Updated Name" }
      }

      assert_redirected_to admin_run_statuses_path
      @run_status.reload
      assert_equal "Updated Name", @run_status.name
    end

    test "update fails with blank name" do
      log_in_as(@admin)
      original_name = @run_status.name

      patch admin_run_status_url(@run_status), params: {
        run_status: { name: "" }
      }

      assert_response :unprocessable_entity
      @run_status.reload
      assert_equal original_name, @run_status.name
    end

    test "update fails with duplicate name" do
      log_in_as(@admin)
      other = RunStatus.create!(name: "Other Status")

      patch admin_run_status_url(other), params: {
        run_status: { name: @run_status.name }
      }

      assert_response :unprocessable_entity
      other.reload
      assert_equal "Other Status", other.name
    end

    # Destroy
    test "destroy deletes run status without computers" do
      log_in_as(@admin)
      run_status = RunStatus.create!(name: "Deletable")

      assert_difference "RunStatus.count", -1 do
        delete admin_run_status_url(run_status)
      end

      assert_redirected_to admin_run_statuses_path
    end

    test "destroy fails when run status has computers" do
      log_in_as(@admin)
      # @run_status has computers via fixtures

      assert_no_difference "RunStatus.count" do
        delete admin_run_status_url(@run_status)
      end

      assert_redirected_to admin_run_statuses_path
    end

    # Authorization
    test "non-admin cannot access run statuses" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get admin_run_statuses_url

      assert_redirected_to root_path
    end

    test "non-admin cannot manage run statuses" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")
      run_status = run_statuses(:working)

      get new_admin_run_status_url
      assert_redirected_to root_path

      assert_no_difference "RunStatus.count" do
        post admin_run_statuses_url, params: { run_status: { name: "Blocked" } }
      end
      assert_redirected_to root_path

      get edit_admin_run_status_url(run_status)
      assert_redirected_to root_path

      patch admin_run_status_url(run_status), params: { run_status: { name: "Blocked" } }
      assert_redirected_to root_path

      assert_no_difference "RunStatus.count" do
        delete admin_run_status_url(run_status)
      end
      assert_redirected_to root_path
    end
  end
end
