require 'ostruct'
require 'hamster'
require_relative 'card'
require_relative 'cards'
require_relative 'dealer'
require_relative 'game'
require_relative 'hand_runner'
require_relative 'stage_runner'

module PokerEngine
  VERSION = '0.1.0'.freeze
  POSITIONS_ORDER = {
    preflop: %i(UTG MP CO D SB BB).freeze,
    postflop: %i(SB BB UTG MP CO D).freeze
  }.freeze

  # more OOP API for Game
  class CachedGame
    attr_reader :states

    def initialize(initial_state, &event_handler)
      @states = [initial_state]
      @event_handler = event_handler
      @game = Game.new
    end

    def start
      new_state, events = @game.start(state).values_at(:state, :events)
      @states << new_state
      events.each { |event| @event_handler.call event }

      state
    end

    def run(move)
      new_state, events = @game.run(state, move).values_at(:state, :events)
      @states << new_state
      events.each do |event|
        @event_handler.call event
      end

      state
    end

    def state
      @states.last
    end
  end

  module_function

  def initial_state(players, small_blind: 10, big_blind: 20)
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
          last_move: {}
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
      winner_id: nil
    )
  end
end
