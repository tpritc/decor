class CreateComputers < ActiveRecord::Migration[8.1]
  def change
    create_table :computers do |t|
      t.references :owner, null: false, foreign_key: true
      t.references :computer_model, null: false, foreign_key: true
      t.string :serial_number
      t.text :description
      t.string :condition, null: false
      t.string :run_status, null: false, default: "unknown"
      t.text :history

      t.timestamps
    end

    add_index :computers, :condition
    add_index :computers, :run_status
  end
end
