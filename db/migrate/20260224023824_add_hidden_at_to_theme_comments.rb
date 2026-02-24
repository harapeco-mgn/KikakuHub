class AddHiddenAtToThemeComments < ActiveRecord::Migration[7.2]
  def change
    add_column :theme_comments, :hidden_at, :datetime
    add_index :theme_comments, :hidden_at
  end
end
