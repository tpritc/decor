require "test_helper"

class ComponentTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    component = Component.new(
      owner: owners(:one),
      component_type: component_types(:memory_board)
    )
    assert component.valid?
  end

  test "valid with optional computer" do
    component = Component.new(
      owner: owners(:one),
      computer: computers(:alice_pdp11),
      component_type: component_types(:memory_board)
    )
    assert component.valid?
  end

  test "valid without computer (spare component)" do
    component = Component.new(
      owner: owners(:one),
      computer: nil,
      component_type: component_types(:disk_drive),
      description: "Spare drive"
    )
    assert component.valid?
  end

  test "invalid without owner" do
    component = Component.new(
      component_type: component_types(:memory_board)
    )
    assert_not component.valid?
    assert_includes component.errors[:owner], "must exist"
  end

  test "invalid without component_type" do
    component = Component.new(
      owner: owners(:one)
    )
    assert_not component.valid?
    assert_includes component.errors[:component_type], "must exist"
  end

  test "belongs to owner" do
    component = components(:pdp11_memory)
    assert_equal owners(:one), component.owner
  end

  test "belongs to computer (optional)" do
    component = components(:pdp11_memory)
    assert_equal computers(:alice_pdp11), component.computer
  end

  test "spare component has no computer" do
    component = components(:spare_disk)
    assert_nil component.computer
  end

  test "belongs to component_type" do
    component = components(:pdp11_memory)
    assert_equal component_types(:memory_board), component.component_type
  end
end
