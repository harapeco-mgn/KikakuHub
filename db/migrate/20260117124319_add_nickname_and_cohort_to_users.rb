class AddNicknameAndCohortToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :nickname, :string, null: false, default: "ユーザー"
    add_column :users, :cohort, :integer, null: false, default: 0

    add_index :users, :nickname
    add_index :users, :cohort
  end
end
