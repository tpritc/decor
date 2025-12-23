class AddAdminToOwners < ActiveRecord::Migration[8.1]
  def change
    add_column :owners, :admin, :boolean, default: false, null: false
  end
end
