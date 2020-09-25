class CreateRooms < ActiveRecord::Migration[6.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.decimal :small_blind, precision: 15, scale: 2
      t.decimal :big_blind, precision: 15, scale: 2

      t.timestamps
    end
  end
end
