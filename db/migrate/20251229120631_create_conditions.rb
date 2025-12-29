class CreateConditions < ActiveRecord::Migration[8.1]
  def change
    create_table :conditions do |t|
      t.string :name

      t.timestamps
    end
    add_index :conditions, :name, unique: true
  end
end
