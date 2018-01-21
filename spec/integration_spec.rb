require_relative 'spec_helper'

module PokerEngine
  describe 'Test in integration' do
    let(:players) do
      [
        { id: 0, balance: 1000 },
        { id: 1, balance: 400 },
        { id: 2, balance: 900 },
      ].freeze
    end

    it 'plays poker game with many stages' do
      events_queue = []
      handler = lambda do |(_old_state, action), _state|
        events_queue << action
      end

      state = Game.start players, small_blind: 10, big_blind: 20, deck_seed: 2, &handler

      expect(state[:players][0][:cards].count).to eq 2
      expect(events_queue.last).to eq(type: :move_request, player_id: 0)

      state = Game.next state, type: :raise, bet: 60, player_id: 0, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 1)

      state = Game.next state, type: :call, player_id: 1, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 2)

      state = Game.next state, type: :raise, bet: 150, player_id: 2, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 0)

      state = Game.next state, type: :call, player_id: 0, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 1)
      expect(state[:board].count).to be_zero

      state = Game.next state, type: :fold, player_id: 1, &handler

      expect(state[:board].count).to eq 3
      expect(state[:pot]).to eq(360)

      expect(events_queue.last).to eq(type: :move_request, player_id: 2)

      state = Game.next state, type: :raise, bet: 150, player_id: 2, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 0)

      state = Game.next state, type: :call, player_id: 0, &handler

      expect(state[:board].count).to eq 4
      expect(state[:pot]).to eq 660

      expect(events_queue.last).to eq(type: :move_request, player_id: 2)

      state = Game.next state, type: :check, player_id: 2, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 0)

      state = Game.next state, type: :check, player_id: 0, &handler

      expect(state[:board].count).to eq 5

      state = Game.next state, type: :check, player_id: 2, &handler

      expect(events_queue.last).to eq(type: :move_request, player_id: 0)

      state = Game.next state, type: :check, player_id: 0, &handler

      expect(state[:winner_ids]).to contain_exactly 1
      expect(state[:top_hands].count).to eq 3
    end
  end
end
