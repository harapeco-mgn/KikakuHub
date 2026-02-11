class AddConvertedEventUrlToThemes < ActiveRecord::Migration[7.2]
  def change
    add_column :themes, :converted_event_url, :string
  end
end
