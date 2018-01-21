module PokerEngine
  class Card
    COLORS = { spade: :spade, club: :club, heart: :heart, diamond: :diamond }.freeze
    RANKS = (2..10).to_a.map(&:to_s) + %w(J Q K A)

    def self.french_deck
      Card::RANKS
        .product(Card::COLORS.values)
        .map { |rank, color| Card.new rank, color }
    end

    attr_reader :rank, :color

    def initialize(rank, color)
      @rank = rank
      @color = color
    end

    def value
      @value ||= RANKS.index rank
    end

    def to_s
      "#{@rank}#{@color[0]}"
    end
  end
end
