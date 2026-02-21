class AddExpiresAtToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :expires_at, :datetime
  end
end
