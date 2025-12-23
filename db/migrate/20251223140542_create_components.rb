class CreateComponents < ActiveRecord::Migration[8.1]
  def change
    create_table :components do |t|
      t.references :owner, null: false, foreign_key: true
      t.references :computer, foreign_key: true
      t.references :component_type, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
