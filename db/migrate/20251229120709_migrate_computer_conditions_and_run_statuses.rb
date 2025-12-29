class MigrateComputerConditionsAndRunStatuses < ActiveRecord::Migration[8.1]
  CONDITIONS_MAP = {
    "original" => "Completely original",
    "original_repaired" => "Completely original with small repairs",
    "modified" => "Original with options replaced or removed",
    "built" => "Built from parts"
  }.freeze

  RUN_STATUSES_MAP = {
    "unknown" => "Unknown",
    "working" => "Working",
    "working_problems" => "Working with a few problems",
    "repair" => "Under repair",
    "defective" => "Defective"
  }.freeze

  def up
    # Add foreign key columns
    add_reference :computers, :condition, foreign_key: true
    add_reference :computers, :run_status, foreign_key: true

    # Create condition records and map existing data
    CONDITIONS_MAP.each do |key, name|
      condition = Condition.create!(name: name)
      execute <<-SQL
        UPDATE computers SET condition_id = #{condition.id} WHERE condition = '#{key}'
      SQL
    end

    # Create run status records and map existing data
    RUN_STATUSES_MAP.each do |key, name|
      run_status = RunStatus.create!(name: name)
      execute <<-SQL
        UPDATE computers SET run_status_id = #{run_status.id} WHERE run_status = '#{key}'
      SQL
    end

    # Remove old columns
    remove_column :computers, :condition
    remove_column :computers, :run_status

    # Add NOT NULL constraints
    change_column_null :computers, :condition_id, false
    change_column_null :computers, :run_status_id, false
  end

  def down
    # Add back the old columns
    add_column :computers, :condition, :string
    add_column :computers, :run_status, :string

    # Map data back to old format
    CONDITIONS_MAP.each do |key, name|
      condition = Condition.find_by(name: name)
      next unless condition
      execute <<-SQL
        UPDATE computers SET condition = '#{key}' WHERE condition_id = #{condition.id}
      SQL
    end

    RUN_STATUSES_MAP.each do |key, name|
      run_status = RunStatus.find_by(name: name)
      next unless run_status
      execute <<-SQL
        UPDATE computers SET run_status = '#{key}' WHERE run_status_id = #{run_status.id}
      SQL
    end

    # Remove foreign key columns
    remove_reference :computers, :condition, foreign_key: true
    remove_reference :computers, :run_status, foreign_key: true

    # Delete the records
    Condition.delete_all
    RunStatus.delete_all

    # Add back constraints
    change_column_null :computers, :condition, false
    change_column_default :computers, :run_status, "unknown"
  end
end
