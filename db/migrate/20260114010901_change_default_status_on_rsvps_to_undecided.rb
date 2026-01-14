class ChangeDefaultStatusOnRsvpsToUndecided < ActiveRecord::Migration[7.2]
  def up
    change_column_default :rsvps, :status, from: 0, to: 2

    # もし「第2ボタンだけ押してRSVPが作られ、status=0(attending)になった」可能性があるなら救済
    rsvp = Class.new(ActiveRecord::Base) { self.table_name = "rsvps" }
    rsvp.where(status: 0, secondary_interest: true).update_all(status: 2)
  end

  def down
    change_column_default :rsvps, :status, from: 2, to: 0
  end
end
