require "test_helper"

class ComputerModelTest < ActiveSupport::TestCase
  test "valid with name" do
    computer_model = ComputerModel.new(name: "PDP-11/45")
    assert computer_model.valid?
  end

  test "invalid without name" do
    computer_model = ComputerModel.new(name: nil)
    assert_not computer_model.valid?
    assert_includes computer_model.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    existing = computer_models(:pdp11_70)
    duplicate = ComputerModel.new(name: existing.name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many computers" do
    computer_model = computer_models(:pdp11_70)
    assert_respond_to computer_model, :computers
  end
end
