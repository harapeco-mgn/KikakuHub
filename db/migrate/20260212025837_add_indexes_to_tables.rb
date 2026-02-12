class AddIndexesToTables < ActiveRecord::Migration[7.2]
  def change
    add_index :availability_slots, :category
    add_index :availability_slots, [:category, :wday]
    add_index :themes, :category
    add_index :themes, :created_at
  end
end
