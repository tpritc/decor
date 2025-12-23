require "test_helper"

class ComponentTypeTest < ActiveSupport::TestCase
  test "valid with name" do
    component_type = ComponentType.new(name: "Graphics Card")
    assert component_type.valid?
  end

  test "invalid without name" do
    component_type = ComponentType.new(name: nil)
    assert_not component_type.valid?
    assert_includes component_type.errors[:name], "can't be blank"
  end

  test "name must be unique" do
    existing = component_types(:memory_board)
    duplicate = ComponentType.new(name: existing.name)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "has many components" do
    component_type = component_types(:memory_board)
    assert_respond_to component_type, :components
  end
end
