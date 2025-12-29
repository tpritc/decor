require "test_helper"

class RunStatusTest < ActiveSupport::TestCase
  test "valid with name" do
    run_status = RunStatus.new(name: "Test Status")
    assert run_status.valid?
  end

  test "invalid without name" do
    run_status = RunStatus.new(name: nil)
    assert_not run_status.valid?
    assert_includes run_status.errors[:name], "can't be blank"
  end

  test "invalid with duplicate name" do
    RunStatus.create!(name: "Unique Status")
    run_status = RunStatus.new(name: "Unique Status")
    assert_not run_status.valid?
    assert_includes run_status.errors[:name], "has already been taken"
  end

  test "has many computers" do
    run_status = run_statuses(:working)
    assert_respond_to run_status, :computers
  end

  test "cannot destroy when computers exist" do
    run_status = run_statuses(:working)
    assert_not run_status.computers.empty?
    assert_not run_status.destroy
    assert_includes run_status.errors[:base], "Cannot delete record because dependent computers exist"
  end

  test "can destroy when no computers exist" do
    run_status = RunStatus.create!(name: "Deletable Status")
    assert run_status.computers.empty?
    assert run_status.destroy
  end
end
