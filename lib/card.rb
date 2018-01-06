module PokerEngine
  class Card
    NUMBER_RANGE = (1..14).freeze
    COLORS = { spade: :spade, club: :club, heart: :heart, diamond: :diamond }.freeze

    attr_reader :number, :color

    def initialize(number, color)
      @number = number
      @color = color
    end

    def to_s
      "#{@number}#{@color[0]}"
    end
  end
end
