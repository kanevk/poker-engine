module PokerEngine
  class StateOperations
    CARDS_COUNT_PER_STAGE_START = { flop: 3, turn: 1, river: 1 }.freeze
    STAGES = %i(preflop flop turn river).freeze

    attr_reader :state

    def initialize(state)
      @state = state
    end

    def player_id_by(position:)
      players.find { |_id, player| player[:position] == position }.first
    end

    def next_stage?
      state[:current_stage] != :river
    end

    def next_stage
      STAGES.fetch STAGES.index(state[:current_stage]) + 1
    end

    def stage_cards_count
      StateOperations::CARDS_COUNT_PER_STAGE_START.fetch state[:current_stage]
    end

    def next_player_id
      ordered_player_ids.cycle.each_with_index.find do |id, order_index|
        order_index > ordered_player_ids.index(state[:current_player_id]) &&
          players[id][:active]
      end.first
    end

    def one_player_left?
      players.count { |_, player| player[:active] } == 1
    end

    def active_players
      players.select { |_, player| player[:active] }
    end

    NO_ACTIVE_FILTER = Object.new
    def ordered_player_ids(active: NO_ACTIVE_FILTER)
      raise 'Unexpected state' unless state[:current_stage]

      positions = Game::POSITIONS_ORDER[state[:current_stage] == :preflop ? :preflop : :postflop]

      players.each_with_object(Array.new(players.count)) do |(id, player), ordered|
        next if active != NO_ACTIVE_FILTER && active != player[:active]

        ordered[positions.index player[:position]] = id
      end.compact
    end

    def first_player_id
      ordered_player_ids(active: true).first
    end

    private

    def players
      state[:players]
    end
  end
end
