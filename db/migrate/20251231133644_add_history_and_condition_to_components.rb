class AddHistoryAndConditionToComponents < ActiveRecord::Migration[8.1]
  def change
    add_column :components, :history, :text
    add_reference :components, :condition, foreign_key: true
  end
end
