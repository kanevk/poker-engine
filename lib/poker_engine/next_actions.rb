module PokerEngine
  module NextActions
    def self.call(state)
      state_operations = StateOperations.new state

      case state.dig :last_action, :type
      when :game_start
        [
          { type: :next_stage, stage: :preflop },
          { type: :take_small_blind, player_id: state_operations.player_id_by(position: :SB) },
          { type: :take_big_blind, player_id: state_operations.player_id_by(position: :BB) },
        ]
      when :take_big_blind
        state_operations.ordered_player_ids.map do |id|
          { type: :distribute_to_player, player_id: id }
        end
      when :distribute_to_player, :distribute_to_board
        [{ type: :move_request, player_id: state_operations.first_player_id }]
      when :check, :call, :raise, :fold
        player_id = state_operations.next_player_id

        if player_id == state[:current_player_id] || state_operations.one_player_left?
          [{ type: :game_end, winner_ids: [player_id] }]
        elsif player_id == state[:aggressor_id] && !state_operations.next_stage?
          players = Hamster.to_ruby state[:players].values

          [{
            type: :game_end,
            top_hands: HandEvaluator.find_top_hands(players, state[:board].to_a),
            winner_ids: HandEvaluator.find_winners(players, state[:board].to_a),
          }]
        elsif player_id == state[:aggressor_id]
          [{ type: :next_stage, stage: state_operations.next_stage }]
        else
          [{ type: :move_request, player_id: player_id }]
        end
      when :next_stage
        [{ type: :distribute_to_board, cards_count: state_operations.stage_cards_count }]
      else
        raise 'error'
      end
    end
  end
end
