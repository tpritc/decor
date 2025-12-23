require "test_helper"

module Admin
  class ComputerModelsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @admin = owners(:one)
      @computer_model = computer_models(:pdp11_70)
    end

    def log_in_as(owner, password: "password123")
      post session_url, params: { user_name: owner.user_name, password: password }
      follow_redirect!
    end

    # Index
    test "index displays computer models" do
      log_in_as(@admin)

      get admin_computer_models_url

      assert_response :success
      assert_select "h1", "Computer Models"
      assert_select "td", @computer_model.name
    end

    # New
    test "new displays form" do
      log_in_as(@admin)

      get new_admin_computer_model_url

      assert_response :success
      assert_select "h1", "New Computer Model"
      assert_select "input[name='computer_model[name]']"
    end

    # Create
    test "create adds new computer model" do
      log_in_as(@admin)

      assert_difference "ComputerModel.count", 1 do
        post admin_computer_models_url, params: {
          computer_model: { name: "New Model" }
        }
      end

      assert_redirected_to admin_computer_models_path
      assert_match /successfully created/i, flash[:notice]
    end

    test "create fails with blank name" do
      log_in_as(@admin)

      assert_no_difference "ComputerModel.count" do
        post admin_computer_models_url, params: {
          computer_model: { name: "" }
        }
      end

      assert_response :unprocessable_entity
    end

    test "create fails with duplicate name" do
      log_in_as(@admin)

      assert_no_difference "ComputerModel.count" do
        post admin_computer_models_url, params: {
          computer_model: { name: @computer_model.name }
        }
      end

      assert_response :unprocessable_entity
    end

    # Edit
    test "edit displays form" do
      log_in_as(@admin)

      get edit_admin_computer_model_url(@computer_model)

      assert_response :success
      assert_select "h1", "Edit Computer Model"
      assert_select "input[value='#{@computer_model.name}']"
    end

    # Update
    test "update changes computer model" do
      log_in_as(@admin)

      patch admin_computer_model_url(@computer_model), params: {
        computer_model: { name: "Updated Name" }
      }

      assert_redirected_to admin_computer_models_path
      @computer_model.reload
      assert_equal "Updated Name", @computer_model.name
    end

    test "update fails with blank name" do
      log_in_as(@admin)
      original_name = @computer_model.name

      patch admin_computer_model_url(@computer_model), params: {
        computer_model: { name: "" }
      }

      assert_response :unprocessable_entity
      @computer_model.reload
      assert_equal original_name, @computer_model.name
    end

    test "update fails with duplicate name" do
      log_in_as(@admin)
      other = ComputerModel.create!(name: "Other Model")

      patch admin_computer_model_url(other), params: {
        computer_model: { name: @computer_model.name }
      }

      assert_response :unprocessable_entity
      other.reload
      assert_equal "Other Model", other.name
    end

    # Destroy
    test "destroy deletes computer model without computers" do
      log_in_as(@admin)
      computer_model = ComputerModel.create!(name: "Deletable")

      assert_difference "ComputerModel.count", -1 do
        delete admin_computer_model_url(computer_model)
      end

      assert_redirected_to admin_computer_models_path
    end

    test "destroy fails when computer model has computers" do
      log_in_as(@admin)
      # @computer_model has computers via fixtures

      assert_no_difference "ComputerModel.count" do
        delete admin_computer_model_url(@computer_model)
      end

      assert_redirected_to admin_computer_models_path
    end

    # Authorization
    test "non-admin cannot access computer models" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")

      get admin_computer_models_url

      assert_redirected_to root_path
    end

    test "non-admin cannot manage computer models" do
      non_admin = owners(:two)
      log_in_as(non_admin, password: "password456")
      computer_model = computer_models(:pdp11_70)

      get new_admin_computer_model_url
      assert_redirected_to root_path

      assert_no_difference "ComputerModel.count" do
        post admin_computer_models_url, params: { computer_model: { name: "Blocked" } }
      end
      assert_redirected_to root_path

      get edit_admin_computer_model_url(computer_model)
      assert_redirected_to root_path

      patch admin_computer_model_url(computer_model), params: { computer_model: { name: "Blocked" } }
      assert_redirected_to root_path

      assert_no_difference "ComputerModel.count" do
        delete admin_computer_model_url(computer_model)
      end
      assert_redirected_to root_path
    end
  end
end
