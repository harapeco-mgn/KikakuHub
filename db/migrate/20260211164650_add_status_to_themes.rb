class AddStatusToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :status, :integer, default: 0, null: false
  end
end
