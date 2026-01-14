class AddSecondaryFieldsToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :secondary_enabled, :boolean, null: false, default: false
    add_column :themes, :secondary_label, :string
  end
end
