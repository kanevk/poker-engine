require_relative 'hand_index'

module PokerEngine
  module HandEvaluator
    module_function

    def find_top_hands(players, board)
      players
        .map do |id:, cards:, **|
          cards = board + cards
          player_top_hand = cards.combination(5)
                                 .map do |five_cards|
                                   HandIndex.new(Cards.new(five_cards))
                                 end
                                 .max

          [id, player_top_hand]
        end
        .to_h
    end

    def find_winners(players, board)
      top_hand_per_player_id = find_top_hands(players, board)

      best_hand = top_hand_per_player_id.values.max

      top_hand_per_player_id
        .map { |player_id, hand| hand == best_hand ? player_id : nil }
        .compact
    end
  end
end
