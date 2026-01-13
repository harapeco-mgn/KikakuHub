class CreateThemes < ActiveRecord::Migration[7.2]
  def change
    create_table :themes do |t|
      t.references :community, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :category
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
