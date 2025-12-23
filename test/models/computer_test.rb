require "test_helper"

class ComputerTest < ActiveSupport::TestCase
  test "valid with required attributes" do
    computer = Computer.new(
      owner: owners(:one),
      computer_model: computer_models(:pdp11_70),
      condition: :original
    )
    assert computer.valid?
  end

  test "invalid without owner" do
    computer = Computer.new(
      computer_model: computer_models(:pdp11_70),
      condition: :original
    )
    assert_not computer.valid?
    assert_includes computer.errors[:owner], "must exist"
  end

  test "invalid without computer_model" do
    computer = Computer.new(
      owner: owners(:one),
      condition: :original
    )
    assert_not computer.valid?
    assert_includes computer.errors[:computer_model], "must exist"
  end

  test "invalid without condition" do
    computer = Computer.new(
      owner: owners(:one),
      computer_model: computer_models(:pdp11_70),
      condition: nil
    )
    assert_not computer.valid?
    assert_includes computer.errors[:condition], "can't be blank"
  end

  test "run_status defaults to unknown" do
    computer = Computer.new(
      owner: owners(:one),
      computer_model: computer_models(:pdp11_70),
      condition: :original
    )
    assert_equal "unknown", computer.run_status
  end

  test "condition enum values" do
    assert_equal %w[original original_repaired modified built], Computer.conditions.keys
  end

  test "run_status enum values" do
    assert_equal %w[unknown working working_problems repair defective], Computer.run_statuses.keys
  end

  test "condition_label returns human readable label" do
    computer = computers(:alice_pdp11)
    assert_equal "Completely original", computer.condition_label
  end

  test "run_status_label returns human readable label" do
    computer = computers(:bob_pdp8)
    assert_equal "Working with a few problems", computer.run_status_label
  end

  test "has many components" do
    computer = computers(:alice_pdp11)
    assert_respond_to computer, :components
  end

  test "all condition labels are defined" do
    Computer::CONDITIONS.each do |key, label|
      computer = Computer.new(condition: key)
      assert_equal label, computer.condition_label, "Missing label for condition: #{key}"
    end
  end

  test "all run_status labels are defined" do
    Computer::RUN_STATUSES.each do |key, label|
      computer = Computer.new(run_status: key)
      assert_equal label, computer.run_status_label, "Missing label for run_status: #{key}"
    end
  end
end
