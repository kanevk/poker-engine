class AddSeatsToRooms < ActiveRecord::Migration[6.0]
  def change
    add_column :rooms, :seats, :integer, array: true, null: false, default: []
  end
end
