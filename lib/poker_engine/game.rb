require_relative 'reducer'

module PokerEngine
  module Game
    POSITIONS_ORDER = {
      preflop: %i(UTG MP CO D SB BB).freeze,
      postflop: %i(SB BB UTG MP CO D).freeze,
    }.freeze

    module_function

    def start(*args, &handler)
      state = initial_state(*args)
      run(state, &handler)
    end

    def next(state, player_action, &handler)
      state = Reducer.call state, player_action

      run(state, &handler)
    end

    def run(state, &handler)
      subscribed_reducer = lambda do |old_state, action|
        new_state = Reducer.call old_state, action
        handler&.call [old_state, action], new_state

        new_state
      end

      loop do
        break state if state[:pending_request] || state[:game_ended]

        actions = NextActions.call(state)
        state = actions.reduce(state, &subscribed_reducer)
      end
    end

    # TODO: remove blinds defaults
    def initial_state(players, small_blind: 10, big_blind: 20, deck_seed: 1)
      reversed_position_order = POSITIONS_ORDER[:preflop].reverse
      positions = players.map.with_index do |player, index|
        last_index = players.count - 1

        [player[:id], reversed_position_order[last_index - index]]
      end.to_h

      normalized_players = players.map do |id:, balance:, **|
        [
          id,
          {
            id: id,
            active: true,
            balance: balance,
            money_in_pot: 0,
            position: positions[id],
            cards: [],
            last_move: {},
          },
        ]
      end.to_h

      Hamster.from(
        players: normalized_players,
        aggressor_id: nil,
        board: [],
        small_blind: small_blind,
        big_blind: big_blind,
        pot: 0,
        pending_request: false,
        winner_ids: [],
        top_hands: {},
        game_ended: false,
        last_action: { type: :game_start },
        current_stage: nil,
        current_player_id: nil,
        deck: Card.french_deck.shuffle(random: Random.new(deck_seed))
      )
    end
  end
end
