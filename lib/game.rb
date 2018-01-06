require 'English'

module PokerEngine
  class Game
    def initialize
      @hand_runner = HandRunner.new
    end

    def start(state)
      run state, OpenStruct.new(type: :game_start)
    end

    def run(old_state, action)
      state = reduce action, old_state

      @hand_runner.run(state) do |new_action, new_state|
        reduce new_action, new_state
      end
    end

    # actions should be immutable
    def reduce(action, state)
      case action.type
      when /take_(?<blind_kind>big_blind|small_blind)/
        blind_size = state.fetch($LAST_MATCH_INFO[:blind_kind].to_sym)

        state
          .update_in(:players, action.player_id) do |player|
            player
              .put(:balance) { |b| b - blind_size }
              .put(:money_in_pot) { |mip| mip + blind_size }
          end
          .put(:pot) { |pot| pot + blind_size }
      when :distribute_to_player
        state.update_in(:players, action.player_id, :cards) { |_| action.cards }
      when :distribute_to_board
        state.put(:board) { |current_cards| current_cards + action.cards.dup }
      when :move_request
        state.put(:pending_request, true)
      when :call
        bet = state.dig(:players, state[:aggressor_id], :last_move, :bet) || state[:big_blind]

        # TODO: handle the case when the bet is higher then the current balance
        money_to_give = bet - state.dig(:players, action.player_id, :money_in_pot)

        state
          .update_in(:players, action.player_id) do |player|
            player
              .put(:balance) { |b| b - money_to_give }
              .put(:money_in_pot) { |mip| mip + money_to_give }
              .put(:last_move, action)
          end
          .put(:pot) { |pot| pot + money_to_give }
          .put(:pending_request, false)
          .put(:aggressor_id) { |id| id || action[:player_id] } # HACK: try to get rid of it.
      when :raise
        money_to_give = action.bet - state.dig(:players, action.player_id, :money_in_pot)

        state
          .update_in(:players, action.player_id) do |player|
            player
              .put(:balance) { |b| b - money_to_give }
              .put(:money_in_pot) { |mip| mip + money_to_give }
              .put(:last_move, action)
          end
          .put(:pot) { |pot| pot + money_to_give }
          .put(:aggressor_id, action.player_id)
          .put(:pending_request, false)
      when :check
        state
          .put(:pending_request, false)
          .put(:aggressor_id) { |id| id || action[:player_id] } # HACK: try to get rid of it.
      when :fold
        state
          .update_in(:players, action.player_id) do |player|
            player.put(:active, false).put(:last_move, action)
          end
          .put(:pending_request, false)
      when :game_start
        state
      when :preflop_start
        state.put(:aggressor_id, nil)
      when :flop_start
        state
          .put(:aggressor_id, nil)
          .put(:players) do |players|
            players.map { |id, player| [id, player.put(:money_in_pot, 0)] }
          end
      when :turn_start
        state
          .put(:aggressor_id, nil)
          .put(:players) do |players|
            players.map { |id, player| [id, player.put(:money_in_pot, 0)] }
          end
      when :river_start
        state
          .put(:aggressor_id, nil)
          .put(:players) do |players|
            players.map { |id, player| [id, player.put(:money_in_pot, 0)] }
          end
      when :game_end
        state.put(:winner_id, action.winner_id)
      else
        # TODO: remove me
        raise 'unknown action'
      end
    end
  end
end
