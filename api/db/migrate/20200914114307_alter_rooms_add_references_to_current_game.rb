class AlterRoomsAddReferencesToCurrentGame < ActiveRecord::Migration[6.0]
  def change
    change_table :rooms do |t|
      t.references :current_game, index: true, foreign_key: { to_table: 'games' }
    end
  end
end
