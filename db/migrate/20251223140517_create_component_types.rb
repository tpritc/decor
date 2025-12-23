class CreateComponentTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :component_types do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :component_types, :name, unique: true
  end
end
