require "test_helper"

class ConditionTest < ActiveSupport::TestCase
  test "valid with name" do
    condition = Condition.new(name: "Test Condition")
    assert condition.valid?
  end

  test "invalid without name" do
    condition = Condition.new(name: nil)
    assert_not condition.valid?
    assert_includes condition.errors[:name], "can't be blank"
  end

  test "invalid with duplicate name" do
    Condition.create!(name: "Unique Condition")
    condition = Condition.new(name: "Unique Condition")
    assert_not condition.valid?
    assert_includes condition.errors[:name], "has already been taken"
  end

  test "has many computers" do
    condition = conditions(:original)
    assert_respond_to condition, :computers
  end

  test "cannot destroy when computers exist" do
    condition = conditions(:original)
    assert_not condition.computers.empty?
    assert_not condition.destroy
    assert_includes condition.errors[:base], "Cannot delete record because dependent computers exist"
  end

  test "can destroy when no computers exist" do
    condition = Condition.create!(name: "Deletable Condition")
    assert condition.computers.empty?
    assert condition.destroy
  end
end
