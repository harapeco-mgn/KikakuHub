class AddUniqueIndexToRsvps < ActiveRecord::Migration[7.2]
  def change
    add_index :rsvps, [ :user_id, :theme_id ], unique: true
  end
end
