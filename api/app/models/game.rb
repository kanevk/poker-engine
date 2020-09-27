# == Schema Information
#
# Table name: games
#
#  id         :bigint           not null, primary key
#  room_id    :bigint           not null
#  state      :json
#  version    :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Game < ApplicationRecord
  State = Struct.new(:current_player_id, keyword_init: true)

  belongs_to :room
  serialize :state

  def update_state(new_state)
    update!(state: new_state, version: SecureRandom.uuid)
  end
end
