class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.string :reportable_type, null: false
      t.bigint :reportable_id, null: false
      t.text :reason, null: false
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    add_index :reports, %i[reportable_type reportable_id]
    add_index :reports, %i[reporter_id reportable_type reportable_id], unique: true, name: "index_reports_on_reporter_and_reportable"
  end
end
