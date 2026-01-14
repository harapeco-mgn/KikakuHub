class FixSecondaryEnabledOnThemes < ActiveRecord::Migration[7.2]
  def up
    execute "UPDATE themes SET secondary_enabled = 0 WHERE secondary_enabled IS NULL"
    change_column_default :themes, :secondary_enabled, from: nil, to: false
    change_column_null :themes, :secondary_enabled, false
  end

  def down
    change_column_null :themes, :secondary_enabled, true
    change_column_default :themes, :secondary_enabled, from: false, to: nil
  end
end