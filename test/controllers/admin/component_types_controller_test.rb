require "test_helper"

module Admin
  class ComponentTypesControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = owners(:one)
      @component_type = component_types(:memory_board)
    end

    def log_in_as(owner, password: "password123")
      post session_url, params: { user_name: owner.user_name, password: password }
      follow_redirect!
    end

    # Index
    test "index displays component types" do
      log_in_as(@admin)

      get admin_component_types_url

      assert_response :success
      assert_select "h1", "Component Types"
      assert_select "td", @component_type.name
    end

    # New
    test "new displays form" do
      log_in_as(@admin)

      get new_admin_component_type_url

      assert_response :success
      assert_select "h1", "New Component Type"
      assert_select "input[name='component_type[name]']"
    end

    # Create
    test "create adds new component type" do
      log_in_as(@admin)

      assert_difference "ComponentType.count", 1 do
        post admin_component_types_url, params: {
          component_type: { name: "New Type" }
        }
      end

      assert_redirected_to admin_component_types_path
      assert_match /successfully created/i, flash[:notice]
    end

    test "create fails with blank name" do
      log_in_as(@admin)

      assert_no_difference "ComponentType.count" do
        post admin_component_types_url, params: {
          component_type: { name: "" }
        }
      end

      assert_response :unprocessable_entity
    end

    test "create fails with duplicate name" do
      log_in_as(@admin)

      assert_no_difference "ComponentType.count" do
        post admin_component_types_url, params: {
          component_type: { name: @component_type.name }
        }
      end

      assert_response :unprocessable_entity
    end

    # Edit
    test "edit displays form" do
      log_in_as(@admin)

      get edit_admin_component_type_url(@component_type)

      assert_response :success
      assert_select "h1", "Edit Component Type"
      assert_select "input[value='#{@component_type.name}']"
    end

    # Update
    test "update changes component type" do
      log_in_as(@admin)

      patch admin_component_type_url(@component_type), params: {
        component_type: { name: "Updated Name" }
      }

      assert_redirected_to admin_component_types_path
      @component_type.reload
      assert_equal "Updated Name", @component_type.name
    end

    test "update fails with blank name" do
      log_in_as(@admin)
      original_name = @component_type.name

      patch admin_component_type_url(@component_type), params: {
        component_type: { name: "" }
      }

      assert_response :unprocessable_entity
      @component_type.reload
      assert_equal original_name, @component_type.name
    end

    test "update fails with duplicate name" do
      log_in_as(@admin)
      other = ComponentType.create!(name: "Other Type")

      patch admin_component_type_url(other), params: {
        component_type: { name: @component_type.name }
      }

      assert_response :unprocessable_entity
      other.reload
      assert_equal "Other Type", other.name
    end

    # Destroy
    test "destroy deletes component type without components" do
      log_in_as(@admin)
      component_type = ComponentType.create!(name: "Deletable")

      assert_difference "ComponentType.count", -1 do
        delete admin_component_type_url(component_type)
      end

      assert_redirected_to admin_component_types_path
    end

    test "destroy fails when component type has components" do
      log_in_as(@admin)
      # @component_type has components via fixtures

      assert_no_difference "ComponentType.count" do
        delete admin_component_type_url(@component_type)
      end

      assert_redirected_to admin_component_types_path
    end

    # Authorization
    test "non-admin cannot access component types" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get admin_component_types_url

      assert_redirected_to root_path
    end

    test "non-admin cannot manage component types" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")
      component_type = component_types(:memory_board)

      get new_admin_component_type_url
      assert_redirected_to root_path

      assert_no_difference "ComponentType.count" do
        post admin_component_types_url, params: { component_type: { name: "Blocked" } }
      end
      assert_redirected_to root_path

      get edit_admin_component_type_url(component_type)
      assert_redirected_to root_path

      patch admin_component_type_url(component_type), params: { component_type: { name: "Blocked" } }
      assert_redirected_to root_path

      assert_no_difference "ComponentType.count" do
        delete admin_component_type_url(component_type)
      end
      assert_redirected_to root_path
    end
  end
end
