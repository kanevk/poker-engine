module PokerEngine
  class HandEvaluator
    attr_reader :board

    def initialize(players, board)
      @players = players
      @board = board
    end

    # TODO: Make better interface for accessing
    # the players sorted by a their best hands and
    # find the winner
    def find_winner
      @players
        .map do |player|
          cards = board + player.cards
          player_strongest_hand = cards.combination(5)
                                       .map do |five_cards|
                                         HandIndex.new(five_cards)
                                       end
                                       .max

          [player, player_strongest_hand]
        end
        .max_by { |_, hand| hand }
        .first
    end
  end
end
