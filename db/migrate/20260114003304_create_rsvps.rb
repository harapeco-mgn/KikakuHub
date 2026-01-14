class CreateRsvps < ActiveRecord::Migration[7.0]
  def change
    create_table :rsvps do |t|
      t.references :user, null: false, foreign_key: true
      t.references :theme, null: false, foreign_key: true

      t.integer :status, null: false, default: 0
      t.boolean :secondary_interest, null: false, default: false

      t.timestamps
    end

    add_index :rsvps, %i[user_id theme_id], unique: true
  end
end
