require_relative 'cards'

module PokerEngine
  module HandLevels
    # Abstract class for Hand level
    class BaseLevel
      attr_reader :cards

      def initialize(cards)
        @cards = cards
      end

      def <=>(other)
        unless other.instance_of?(self.class)
          fail "Can't detail compare hands of different level"
        end

        detail_compare(other)
      end

      def detail_compare(other)
        cards.values_desc_by_occurency <=>
          other.cards.values_desc_by_occurency
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
        cards.sorted_values
             .group_by(&:itself)
             .any? { |_, group| group.size == 2 }
      end
    end

    TwoPairs = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_values
             .group_by(&:itself)
             .select { |_, group| group.size == 2 }
             .count
             .eql?(2)
      end
    end

    ThreeOfAKind = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_values
             .group_by(&:itself)
             .one? { |_, group| group.size == 3 }
      end
    end

    Straight = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_values
             .each_cons(2)
             .map { |a, b| a - b }
             .uniq
             .one?
      end

      def detail_compare(other)
        cards.sorted_values.first <=> other.cards.sorted_values.first
      end
    end

    Flush = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.map(&:color).uniq.one?
      end
    end

    FullHouse = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.map(&:value).uniq.count > 1 &&
          OnePair.owns?(cards) &&
          ThreeOfAKind.owns?(cards)
      end
    end

    FourOfAKind = Class.new(BaseLevel) do
      def self.owns?(cards)
        cards.sorted_values
             .group_by(&:itself)
             .one? { |_, group| group.size == 4 }
      end
    end

    StraightFlush = Class.new(BaseLevel) do
      def self.owns?(cards)
        Straight.owns?(cards) && Flush.owns?(cards)
      end

      def detail_compare(other)
        cards.sorted_values.first <=> other.cards.sorted_values.first
      end
    end
  end
end
