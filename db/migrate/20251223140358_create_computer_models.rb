class CreateComputerModels < ActiveRecord::Migration[8.1]
  def change
    create_table :computer_models do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :computer_models, :name, unique: true
  end
end
