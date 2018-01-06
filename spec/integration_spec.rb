require_relative '../lib/poker_engine'
require 'pry'

module PokerEngine
  describe 'Test in integration' do
    let(:players) do
      [
        { id: 0, name: 'John', balance: 1000 },
        { id: 1, name: 'Kamen', balance: 400 },
        { id: 2, name: 'Jenny', balance: 900 }
      ].freeze
    end

    it 'plays poker game with many stages' do
      events_queue = []
      initial_state = ::PokerEngine.initial_state(players, small_blind: 10, big_blind: 20)
      game = CachedGame.new(initial_state) do |event|
        events_queue.push event
      end

      game.start

      expect(game.state[:players][0][:cards].count).to eq 2
      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 0)

      game.run(OpenStruct.new(type: :raise, bet: 60, player_id: 0))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 1)

      game.run(OpenStruct.new(type: :call, player_id: 1))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 2)

      game.run(OpenStruct.new(type: :raise, bet: 150, player_id: 2))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 0)

      game.run(OpenStruct.new(type: :call, player_id: 0))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 1)
      expect(game.state[:board].count).to be_zero

      game.run(OpenStruct.new(type: :fold, player_id: 1))

      expect(game.state[:board].count).to eq 3
      expect(game.state[:pot]).to eq(360)

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 2)

      game.run(OpenStruct.new(type: :raise, bet: 150, player_id: 2))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 0)

      game.run(OpenStruct.new(type: :call, player_id: 0))

      expect(game.state[:board].count).to eq 4
      expect(game.state[:pot]).to eq 660

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 2)

      game.run(OpenStruct.new(type: :check, player_id: 2))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 0)

      game.run(OpenStruct.new(type: :check, player_id: 0))

      expect(game.state[:board].count).to eq 5

      game.run(OpenStruct.new(type: :check, player_id: 2))

      expect(events_queue.last).to have_attributes(type: :move_request, player_id: 0)

      game.run(OpenStruct.new(type: :check, player_id: 0))
    end
  end
end
