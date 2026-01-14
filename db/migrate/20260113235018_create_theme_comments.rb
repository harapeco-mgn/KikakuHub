class CreateThemeComments < ActiveRecord::Migration[7.2]
  def change
    create_table :theme_comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true
      t.text :body, null: false

      t.timestamps
    end
  end
end
