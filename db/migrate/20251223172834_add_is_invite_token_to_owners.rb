class AddIsInviteTokenToOwners < ActiveRecord::Migration[8.1]
  def change
    add_column :owners, :is_invite_token, :boolean
  end
end
