class CreateRunStatuses < ActiveRecord::Migration[8.1]
  def change
    create_table :run_statuses do |t|
      t.string :name

      t.timestamps
    end
    add_index :run_statuses, :name, unique: true
  end
end
