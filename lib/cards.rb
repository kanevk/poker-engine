module PokerEngine
  class Cards
    include Enumerable

    COLOR_BY_FIRST_LETTER = {
      's' => Card::COLORS[:spade],
      'c' => Card::COLORS[:club],
      'h' => Card::COLORS[:heart],
      'd' => Card::COLORS[:diamond]
    }.freeze

    # TODO: Don't make N + 1 queries
    def self.parse(str_cards)
      cards = str_cards
              .split(',')
              .map do |str|
                Card.new str.to_i, COLOR_BY_FIRST_LETTER.fetch(str[-1])
              end

      new(cards)
    end

    attr_reader :cards

    def initialize(cards)
      @cards = cards
    end

    def each(&block)
      cards.each(&block)
    end

    def +(other)
      Cards.new(cards + other.cards)
    end

    # TODO: Make it work with block, too
    def sort
      cards.sort_by(&:number)
    end

    def sorted_numbers
      cards.map(&:number).sort
    end

    def combination(x)
      cards.combination(x).map { |c| Cards.new(c) }
    end

    # Make descending order primary by occurency and secondary by number value
    def numbers_desc_by_occurency
      numbers = cards.map(&:number)

      numbers.sort do |a, b|
        coefficient_occurency = (numbers.count(a) <=> numbers.count(b))

        coefficient_occurency.zero? ? -(a <=> b) : -coefficient_occurency
      end
    end
  end
end
