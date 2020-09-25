class CreateGames < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'

    create_table :games do |t|
      t.references :room, null: false, foreign_key: true, index: true
      t.json :state
      t.uuid :version, default: "gen_random_uuid()", null: false

      t.timestamps
    end
  end
end
