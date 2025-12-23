class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    create_table :invites do |t|
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :sent_at, null: false
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invites, :email
    add_index :invites, :token, unique: true
  end
end
