require 'ostruct'

module PokerEngine
  module Reducer
    def self.call(state, action)
      raise "Unknown action #{action[:type]}" unless allowed_actions.include? action[:type]

      Actions
        .public_send(action[:type], state, action)
        .put(:last_action, action)
    end

    def self.allowed_actions
      @allowed_actions ||= Actions.methods(false)
    end

    module Actions
      module_function

      def game_start(state, **_action)
        state
      end

      def take_small_blind(state, **action)
        take_blind state, action.merge(blind_kind: :small_blind)
      end

      def take_big_blind(state, **action)
        take_blind state, action.merge(blind_kind: :big_blind)
      end

      def distribute_to_player(state, player_id:, **_action)
        new_deck, poped_cards =
          state[:deck].partition.with_index { |_, i| i + 1 <= state[:deck].count - 2 }

        state
          .put(:deck, new_deck)
          .update_in(:players, player_id, :cards) { poped_cards }
      end

      def distribute_to_board(state, cards_count:, **_action)
        new_deck, poped_cards =
          state[:deck].partition.with_index { |_, i| i + 1 <= state[:deck].count - cards_count }

        state
          .put(:deck, new_deck)
          .put(:board) { |board| board + poped_cards }
      end

      def move_request(state, player_id:, **_action)
        state
          .put(:current_player_id, player_id)
          .put(:pending_request, true)
      end

      def call(state, **action)
        bet = state.dig(:players, state[:aggressor_id], :last_move, :bet) || state[:big_blind]
        money_to_give = bet - state.dig(:players, action[:player_id], :money_in_pot)

        pay(state, action.merge(money_to_give: money_to_give))
          .put(:aggressor_id) { |id| id || action[:player_id] } # HACK: try to get rid of it.
      end

      def raise(state, **action)
        money_to_give = action[:bet] - state.dig(:players, action[:player_id], :money_in_pot)

        pay(state, action.merge(money_to_give: money_to_give))
          .put(:aggressor_id, action[:player_id])
      end

      def check(state, player_id:, **_action)
        state
          .put(:pending_request, false)
          .put(:aggressor_id) { |id| id || player_id } # HACK: try to get rid of it.
      end

      def fold(state, **action)
        state
          .update_in(:players, action[:player_id]) do |player|
            player.put(:active, false).put(:last_move, action)
          end
          .put(:pending_request, false)
      end

      def next_stage(state, stage:, **_action)
        state
          .update_in(:players) do |players|
            players.map { |id, player| [id, player.put(:money_in_pot, 0)] }
          end
          .put(:current_stage, stage)
          .put(:aggressor_id, nil)
      end

      def game_end(state, top_hands:, winner_ids:, **_action)
        state
          .put(:top_hands, top_hands)
          .put(:winner_ids, winner_ids)
          .put(:game_ended, true)
      end

      private_class_method def take_blind(state, player_id:, blind_kind:, **_action)
        blind_size = state.fetch blind_kind

        state
          .update_in(:players, player_id) do |player|
            player
              .put(:balance) { |b| b - blind_size }
              .put(:money_in_pot) { |mip| mip + blind_size }
          end
          .put(:pot) { |pot| pot + blind_size }
      end

      # TODO: handle the case when the bet is higher then the current balance
      private_class_method def pay(state, money_to_give:, **action)
        state
          .update_in(:players, action[:player_id]) do |player|
            player
              .put(:balance) { |b| b - money_to_give }
              .put(:money_in_pot) { |mip| mip + money_to_give }
              .put(:last_move, action)
          end
          .put(:pot) { |pot| pot + money_to_give }
          .put(:pending_request, false)
      end
    end
  end
end
