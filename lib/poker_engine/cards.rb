module PokerEngine
  class Cards
    include Enumerable

    COLOR_BY_FIRST_LETTER = {
      's' => Card::COLORS[:spade],
      'c' => Card::COLORS[:club],
      'h' => Card::COLORS[:heart],
      'd' => Card::COLORS[:diamond],
    }.freeze

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

    def to_s
      cards.map(&:to_s).join(', ')
    end

    def each(&block)
      cards.each(&block)
    end

    def +(other)
      Cards.new(cards + other.cards)
    end

    # TODO: Make it work with block, too
    def sort
      cards.sort_by(&:value)
    end

    def sorted_values
      cards.map(&:value).sort
    end

    def combination(x)
      cards.combination(x).map { |c| Cards.new(c) }
    end

    # Make descending order primary by occurency and secondary by value
    def values_desc_by_occurency
      values = cards.map(&:value)

      values.sort do |a, b|
        coefficient_occurency = (values.count(a) <=> values.count(b))

        coefficient_occurency.zero? ? -(a <=> b) : -coefficient_occurency
      end
    end
  end
end
