require_relative 'cards'

module PokerGame
  module HandLevels
    # Abstract class for Hand level
    class BaseLevel
      attr_reader :cards

      def initialize(cards)
        @cards = cards
      end

      def <=>(other)
        unless other.instance_of?(self.class)
          fail "Can't detail detail hands of different level"
        end

        detail_compare(other)
      end

      def detail_compare(other)
        cards.numbers_desc_by_occurency <=>
          other.cards.numbers_desc_by_occurency
      end
    end

    #============================= Levels ======================================

    HighCard = Class.new(BaseLevel) do
      def self.owns?(_cards)
        true
      end
    end

    OnePair = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_numbers
             .group_by(&:itself)
             .any? { |_, group| group.size == 2 }
      end
    end

    TwoPairs = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_numbers
             .group_by(&:itself)
             .select { |_, group| group.size == 2 }
             .count
             .eql?(2)
      end
    end

    ThreeOfAKind = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_numbers
             .group_by(&:itself)
             .one? { |_, group| group.size == 3 }
      end
    end

    Straight = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_numbers
             .each_cons(2)
             .map { |a, b| a - b }
             .uniq
             .one?
      end

      def detail_compare(other)
        cards.sorted_numbers.first <=> other.cards.sorted_numbers.first
      end
    end

    Flush = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.map(&:color).uniq.one?
      end
    end

    FullHouse = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.map(&:number).uniq.many? &&
          OnePair.owns?(cards) &&
          ThreeOfAKind.owns?(cards)
      end
    end

    FourOfAKind = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_numbers
             .group_by(&:itself)
             .one? { |_, group| group.size == 4 }
      end
    end

    StraightFlush = Class.new(BaseLevel) do
      def self.owns?(cards)
        Straight.owns?(cards) && Flush.owns?(cards)
      end

      def detail_compare(other)
        cards.sorted_numbers.first <=> other.cards.sorted_numbers.first
      end
    end
  end
end
