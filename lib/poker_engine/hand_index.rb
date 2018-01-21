require_relative 'hand_levels'

module PokerEngine
  class HandIndex
    # The index is equivalent to the level strength
    RANK_TABLE = [HandLevels::HighCard, HandLevels::OnePair,
                  HandLevels::TwoPairs, HandLevels::ThreeOfAKind,
                  HandLevels::Straight, HandLevels::Flush,
                  HandLevels::FullHouse, HandLevels::FourOfAKind,
                  HandLevels::StraightFlush].freeze

    attr_reader :cards

    def initialize(cards)
      @cards = cards
    end

    def <=>(other)
      outer_level_compare =
        (RANK_TABLE.index(level) <=> RANK_TABLE.index(other.level))

      return outer_level_compare unless outer_level_compare.zero?

      level <=> other.level
    end

    def >(other)
      level <=> other.level
    end

    def level
      @level ||=
        RANK_TABLE.reverse_each.find { |level| level.owns?(cards) }
    end
  end
end
