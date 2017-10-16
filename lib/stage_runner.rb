module PokerEngine
  class StageRunner
    def initialize(player_ids)
      @players_ids = player_ids
    end

    def run(state)
      loop do
        status, player_id = self.next(state).values_at(:status, :player_id)

        break { status: status, state: state, last_player_id: player_id } if status != :running

        state = yield player_id
      end
    end

    def next(state)
      generator.resume(state)
    end

    def generator
      @generator ||= Fiber.new do |state|
        @players_ids.cycle.each do |player_id|
          next unless player_active?(state, player_id)
          break { status: :end, player_id: player_id } if one_player_left?(state)
          break { status: :stop, player_id: player_id } if player_id == state[:aggressor_id]

          state = Fiber.yield status: :running, player_id: player_id
        end
      end
    end

    def player_active?(state, player_id)
      state.dig(:players, player_id, :active)
    end

    def one_player_left?(state)
      state[:players].count { |_, player| player[:active] } == 1
    end
  end
end
