class MakeConditionAndRunStatusOptionalInComputers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :computers, :condition_id, true
    change_column_null :computers, :run_status_id, true
  end
end
