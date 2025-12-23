class AddPasswordResetToOwners < ActiveRecord::Migration[8.1]
  def change
    add_column :owners, :reset_password_token, :string
    add_index :owners, :reset_password_token, unique: true
    add_column :owners, :reset_password_sent_at, :datetime
  end
end
