module PokerEngine
  # Holdem dealer
  class Dealer
    def initialize(player_ids)
      @deck = french_deck.shuffle
      @player_ids = player_ids
    end

    def player_distibution
      first_cards = @deck.pop(@player_ids.count)
      second_cards = @deck.pop(@player_ids.count)
      cards = first_cards.zip(second_cards)

      @player_ids.zip(cards).to_h
    end

    def distribute_flop
      cards = @deck.pop(4)

      cards[1..-1]
    end

    def distribute_turn
      cards = @deck.pop(2)

      [cards.last]
    end
    alias distribute_river distribute_turn

    private

    def french_deck
      all_combinations = Card::NUMBER_RANGE.to_a.product(Card::COLORS.values)

      all_combinations.map { |number, color| Card.new number, color }
    end
  end
end
