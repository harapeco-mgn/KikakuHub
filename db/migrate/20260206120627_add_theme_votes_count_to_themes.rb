class AddThemeVotesCountToThemes < ActiveRecord::Migration[8.0]
  def change
    add_column :themes, :theme_votes_count, :integer, default: 0, null: false

    # 既存データのカウンターキャッシュを初期化
    reversible do |dir|
      dir.up do
        Theme.find_each do |theme|
          Theme.reset_counters(theme.id, :theme_votes)
        end
      end
    end
  end
end
