class CreateAvailabilitySlots < ActiveRecord::Migration[7.2]
  def change
    create_table :availability_slots do |t|
      t.references :user, null: false, foreign_key: true

      # tech/community
      t.integer :category, null: false

      # 0..6（0=月, 6=日 で運用する前提）
      t.integer :wday, null: false

      # 分で保持（例: 19:30 => 1170）
      t.integer :start_minute, null: false
      t.integer :end_minute, null: false

      t.timestamps
    end

    add_index :availability_slots, %i[user_id category wday start_minute end_minute],
              unique: true,
              name: "index_availability_slots_unique_range"

    # DB側の安全柵
    add_check_constraint :availability_slots, "category IN (0, 1)", name: "chk_availability_slots_category"
    add_check_constraint :availability_slots, "wday BETWEEN 0 AND 6", name: "chk_availability_slots_wday"
    add_check_constraint :availability_slots, "start_minute >= 0 AND start_minute < 1440", name: "chk_availability_slots_start_range"
    add_check_constraint :availability_slots, "end_minute > 0 AND end_minute <= 1440", name: "chk_availability_slots_end_range"
    add_check_constraint :availability_slots, "end_minute > start_minute", name: "chk_availability_slots_end_after_start"
    add_check_constraint :availability_slots, "start_minute % 30 = 0", name: "chk_availability_slots_start_step_30"
    add_check_constraint :availability_slots, "end_minute % 30 = 0", name: "chk_availability_slots_end_step_30"
  end
end
