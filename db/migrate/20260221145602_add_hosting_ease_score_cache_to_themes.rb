class AddHostingEaseScoreCacheToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :hosting_ease_score_cache, :integer, default: 0, null: false
    add_index :themes, :hosting_ease_score_cache
  end
end
