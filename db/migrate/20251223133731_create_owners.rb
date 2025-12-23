class CreateOwners < ActiveRecord::Migration[8.1]
  def change
    create_table :owners do |t|
      t.string :user_name
      t.string :real_name
      t.string :website
      t.string :password_digest
      t.string :real_name_visibility
      t.string :country
      t.string :country_visibility
      t.string :email
      t.string :email_visibility

      t.timestamps
    end
    add_index :owners, :user_name, unique: true
    add_index :owners, :real_name_visibility
    add_index :owners, :country
    add_index :owners, :country_visibility
    add_index :owners, :email, unique: true
    add_index :owners, :email_visibility
  end
end
