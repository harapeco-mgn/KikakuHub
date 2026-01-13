class CreateThemeVotes < ActiveRecord::Migration[7.2]
  def change
    create_table :theme_votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true

      t.timestamps
    end

    add_index :theme_votes, [ :user_id, :theme_id ], unique: true
  end
end
