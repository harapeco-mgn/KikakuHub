class AddHiddenAtToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :hidden_at, :datetime
    add_index :themes, :hidden_at
  end
end
