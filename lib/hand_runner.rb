module PokerEngine
  class HandRunner
    def next(state)
      state[:pending_request] ? nil : generator.resume(state)
    end

    def run(state)
      events = []
      while (action = self.next state)
        events << action
        state = yield action, state
      end

      { state: state, events: events }
    end

    def generator
      @generator ||=
        Fiber.new do |state|
          preflop_ordered_players_ids = ordered_player_ids(state, stage: :preflop)
          dealer = Dealer.new preflop_ordered_players_ids

          Fiber.yield OpenStruct.new(type: :take_big_blind,
                                     player_id: preflop_ordered_players_ids[-1])

          Fiber.yield OpenStruct.new(type: :take_small_blind,
                                     player_id: preflop_ordered_players_ids[-2])

          state = Fiber.yield OpenStruct.new(type: :preflop_start)
          _state = dealer.player_distibution.reduce(state) do |_old_state, (player_id, cards)|
            Fiber.yield OpenStruct.new(type: :distribute_to_player, player_id: player_id, cards: cards)
          end

          preflop = StageRunner.new ordered_player_ids(state, stage: :preflop)
          status, last_player_id = preflop.run(state) do |player_id|
            Fiber.yield OpenStruct.new(type: :move_request, player_id: player_id)
          end.values_at(:status, :last_player_id)

          next Fiber.yield OpenStruct.new(type: :game_end, winner_id: last_player_id) if status == :end

          _state = Fiber.yield OpenStruct.new(type: :flop_start)
          state = Fiber.yield OpenStruct.new(type: :distribute_to_board, cards: dealer.distribute_flop)

          flop = StageRunner.new ordered_player_ids(state, stage: :flop)
          status, last_player_id = flop.run(state) do |player_id|
            Fiber.yield OpenStruct.new(type: :move_request, player_id: player_id)
          end.values_at(:status, :last_player_id)

          next Fiber.yield OpenStruct.new(type: :game_end, winner_id: last_player_id) if status == :end

          _state = Fiber.yield OpenStruct.new(type: :turn_start)
          state = Fiber.yield OpenStruct.new(type: :distribute_to_board, cards: dealer.distribute_turn)

          turn = StageRunner.new ordered_player_ids(state, stage: :turn)
          status, last_player_id = turn.run(state) do |player_id|
            Fiber.yield OpenStruct.new(type: :move_request, player_id: player_id)
          end.values_at(:status, :last_player_id)

          next Fiber.yield OpenStruct.new(type: :game_end, winner_id: last_player_id) if status == :end

          _state = Fiber.yield OpenStruct.new(type: :river_start)
          state = Fiber.yield OpenStruct.new(type: :distribute_to_board, cards: dealer.distribute_river)

          river = StageRunner.new ordered_player_ids(state, stage: :river)
          status, last_player_id = river.run(state) do |player_id|
            Fiber.yield OpenStruct.new(type: :move_request, player_id: player_id)
          end.values_at(:status, :last_player_id)

          next Fiber.yield OpenStruct.new(type: :game_end, winner_id: last_player_id) if status == :end

          # TODO: find winner
          raise 'Find winner'

          OpenStruct.new(type: :game_end, winner_id: nil)
        end
    end

    def ordered_player_ids(state, stage:)
      key = (stage == :preflop ? :preflop : :postflop)
      POSITIONS_ORDER[key].map do |position|
        state[:players].find { |_, player| player[:active] && player[:position] == position }&.first
      end.compact!
    end
  end
end
