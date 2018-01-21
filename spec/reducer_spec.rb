require_relative 'spec_helper'

module PokerEngine
  RSpec.describe Reducer do
    describe 'calling it' do
      let(:small_blind) { 10 }
      let(:big_blind) { 20 }
      let(:initial_players) do
        [
          { id: 1, balance: 1000 },
          { id: 2, balance: 1000 },
          { id: 3, balance: 1000 },
        ]
      end

      let(:state) do
        Game.initial_state initial_players, small_blind: small_blind, big_blind: big_blind
      end

      it 'raises an exception when the action is invalid' do
        expect { Reducer.call(double, type: :invalid_action) }.to raise_error(/Unknown action/)
      end

      describe 'starting game' do
        it do
          new_state = Reducer.call state, type: :game_start

          expect(new_state[:last_action]).to eq type: :game_start
        end
      end

      describe 'taking small blind' do
        it "decreases the player's balance with the small blind size" do
          new_state = Reducer.call state, type: :take_small_blind, player_id: 2

          expect(state[:players][2][:balance]).to eq 1000
          expect(new_state[:players][2][:balance]).to eq 1000 - small_blind
        end

        it "increases the player's money in the pot" do
          new_state = Reducer.call state, type: :take_small_blind, player_id: 2

          expect(state[:players][2][:money_in_pot]).to eq 0
          expect(new_state[:players][2][:money_in_pot]).to eq small_blind
        end

        it 'increases the pot size with small blind size' do
          new_state = Reducer.call state, type: :take_small_blind, player_id: 2

          expect(state[:pot]).to eq 0
          expect(new_state[:pot]).to eq small_blind
        end
      end

      describe 'taking big blind' do
        it "decreases the player's balance with the big blind size" do
          new_state = Reducer.call state, type: :take_big_blind, player_id: 2

          expect(state[:players][2][:balance]).to eq 1000
          expect(new_state[:players][2][:balance]).to eq 1000 - big_blind
        end

        it "increases the player's money in the pot" do
          new_state = Reducer.call state, type: :take_big_blind, player_id: 2

          expect(state[:players][2][:money_in_pot]).to eq 0
          expect(new_state[:players][2][:money_in_pot]).to eq big_blind
        end

        it 'increases the pot size with big blind size' do
          new_state = Reducer.call state, type: :take_big_blind, player_id: 2

          expect(state[:pot]).to eq 0
          expect(new_state[:pot]).to eq big_blind
        end
      end

      describe 'distributing cards to a player' do
        it 'removes last two cards from the deck' do
          new_state = Reducer.call state, type: :distribute_to_player, player_id: 2

          expect(new_state[:deck]).to eq state[:deck].pop.pop
        end

        it 'gives two cards to the player' do
          new_state = Reducer.call state, type: :distribute_to_player, player_id: 2

          expect(new_state[:players][2][:cards]).to eq state[:deck].values_at(-2, -1)
        end
      end

      describe 'distributing cards to the board' do
        it 'removes *cards_count cards from the deck' do
          new_state = Reducer.call state, type: :distribute_to_board, cards_count: 3

          expect(new_state[:deck]).to eq state[:deck].pop.pop.pop
        end

        it 'adds *cards_count cards to the board' do
          new_state = Reducer.call state, type: :distribute_to_board, cards_count: 1

          expect(state[:board]).to eq []
          expect(new_state[:board]).to eq [state[:deck].last]
        end
      end

      describe 'making move request' do
        it "sets 'pending_request' to true" do
          new_state = Reducer.call state, type: :move_request, player_id: 2

          expect(state[:pending_request]).to eq false
          expect(new_state[:pending_request]).to eq true
        end

        it 'sets the current player' do
          new_state = Reducer.call state, type: :move_request, player_id: 2

          expect(state[:current_player_id]).not_to eq 2
          expect(new_state[:current_player_id]).to eq 2
        end
      end

      describe 'calling a bet' do
        let(:state) do
          Game
            .initial_state(initial_players, small_blind: 0, big_blind: 0)
            .put(:aggressor_id, 1)
            .update_in(:players, 1) { |aggro| aggro.put(:last_move, type: :raise, bet: 100) }
            .update_in(:players, 2) { |pl| pl.put(:money_in_pot, 40).put(:balance, 960) }
            .put(:pot, 160)
            .put(:pending_request, true)
        end

        it "decreases the player's balance" do
          new_state = Reducer.call state, type: :call, player_id: 2

          expect(state[:players][2][:balance]).to eq 960
          expect(new_state[:players][2][:balance]).to eq 960 - (100 - 40)
        end

        it "increases the player's money in the pot" do
          new_state = Reducer.call state, type: :call, player_id: 2

          expect(state[:players][2][:money_in_pot]).to eq 40
          expect(new_state[:players][2][:money_in_pot]).to eq 100
        end

        it "sets player's last move to be the current action" do
          new_state = Reducer.call state, type: :call, player_id: 2

          expect(state[:players][2][:last_move]).to be_empty
          expect(new_state[:players][2][:last_move]).to eq type: :call, player_id: 2
        end

        it 'increases the pot size' do
          new_state = Reducer.call state, type: :call, player_id: 2

          expect(state[:pot]).to eq 160
          expect(new_state[:pot]).to eq 220
        end

        it "sets 'pending_request' to false" do
          new_state = Reducer.call state, type: :call, player_id: 2

          expect(state[:pending_request]).to eq true
          expect(new_state[:pending_request]).to eq false
        end

        context 'when is first call' do
          it "sets aggressor id to the player's id" do
            state = Game.initial_state initial_players, small_blind: 0, big_blind: 0
            new_state = Reducer.call state, type: :call, player_id: 1

            expect(state[:aggressor_id]).to be_nil
            expect(new_state[:aggressor_id]).to eq 1
          end
        end

        context "when isn't first call" do
          it "doesn't change the aggressor id" do
            state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                        .put(:aggressor_id, 2)
            new_state = Reducer.call state, type: :call, player_id: 1

            expect(state[:aggressor_id]).to eq 2
            expect(new_state[:aggressor_id]).to eq 2
          end
        end
      end

      describe 'increasing a bet' do
        let(:state) do
          Game
            .initial_state(initial_players, small_blind: 0, big_blind: 0)
            .put(:aggressor_id, 1)
            .update_in(:players, 1) { |aggro| aggro.put(:last_move, type: :raise, bet: 100) }
            .update_in(:players, 2) { |pl| pl.put(:money_in_pot, 40).put(:balance, 960) }
            .put(:pot, 160)
            .put(:pending_request, true)
        end

        it "decreases the player's balance" do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:players][2][:balance]).to eq 960
          expect(new_state[:players][2][:balance]).to eq 960 - (160 - 40)
        end

        it "increases the player's money in the pot" do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:players][2][:money_in_pot]).to eq 40
          expect(new_state[:players][2][:money_in_pot]).to eq 160
        end

        it "sets player's last move to be the current action" do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:players][2][:last_move]).to be_empty
          expect(new_state[:players][2][:last_move]).to eq type: :raise, bet: 160, player_id: 2
        end

        it 'increases the pot size' do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:pot]).to eq 160
          expect(new_state[:pot]).to eq 160 + (160 - 40)
        end

        it "sets 'pending_request' to false" do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:pending_request]).to eq true
          expect(new_state[:pending_request]).to eq false
        end

        it 'changes the aggressor id' do
          new_state = Reducer.call state, type: :raise, bet: 160, player_id: 2

          expect(state[:aggressor_id]).to eq 1
          expect(new_state[:aggressor_id]).to eq 2
        end
      end

      describe 'checking' do
        it "sets 'pending_request' to false" do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                      .put(:pending_request, true)
          new_state = Reducer.call state, type: :check, player_id: 2

          expect(state[:pending_request]).to eq true
          expect(new_state[:pending_request]).to eq false
        end

        context 'when is first to check' do
          it "sets aggressor id to the player's id" do
            new_state = Reducer.call state, type: :check, player_id: 1

            expect(state[:aggressor_id]).to be_nil
            expect(new_state[:aggressor_id]).to eq 1
          end
        end

        context "when isn't first to check" do
          it "doesn't change the aggressor id" do
            state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                        .put(:aggressor_id, 2)
            new_state = Reducer.call state, type: :check, player_id: 1

            expect(state[:aggressor_id]).to eq 2
            expect(new_state[:aggressor_id]).to eq 2
          end
        end
      end

      describe 'folding' do
        it 'making the player inactive' do
          new_state = Reducer.call state, type: :fold, player_id: 2

          expect(state[:players][2][:active]).to be true
          expect(new_state[:players][2][:active]).to be false
        end

        it "sets last player's move" do
          new_state = Reducer.call state, type: :fold, player_id: 2

          expect(state[:players][2][:last_move]).to be_empty
          expect(new_state[:players][2][:last_move]).to eq(type: :fold, player_id: 2)
        end

        it "sets 'pending_request' to false" do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                      .put(:pending_request, true)
          new_state = Reducer.call state, type: :fold, player_id: 2

          expect(state[:pending_request]).to eq true
          expect(new_state[:pending_request]).to eq false
        end
      end

      describe 'moving to next stage' do
        it 'sets the new stage' do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                      .put(:current_stage, :preflop)

          new_state = Reducer.call state, type: :next_stage, stage: :flop

          expect(state[:current_stage]).to eq :preflop
          expect(new_state[:current_stage]).to eq :flop
        end

        it 'zeroing the aggressor ID' do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                      .put(:aggressor_id, 1)
          new_state = Reducer.call state, type: :next_stage, stage: :flop

          expect(state[:aggressor_id]).to eq 1
          expect(new_state[:aggressor_id]).to be_nil
        end

        it "zeroing players's money in the pot" do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
                      .update_in(:players) do |players|
                        players.map { |id, player| [id, player.put(:money_in_pot, 100)] }
                      end
          new_state = Reducer.call state, type: :next_stage, stage: :flop

          expect(state[:players][1][:money_in_pot]).to eq 100
          expect(new_state[:players][1][:money_in_pot]).to eq 0
        end
      end

      describe 'ending the game' do
        it 'finds the winners' do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)

          new_state = Reducer.call state, type: :game_end,
                                          winner_ids: [1],
                                          top_hands: { 1 => double, 2 => double, 3 => double }
          expect(state[:winner_ids]).to be_empty
          expect(new_state[:winner_ids]).to contain_exactly(1)
        end

        it "shows players' top hands" do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)
          top_hands = { 1 => double, 2 => double, 3 => double }

          new_state = Reducer.call state, type: :game_end,
                                          winner_ids: [1],
                                          top_hands: top_hands
          expect(state[:top_hands]).to be_empty
          expect(new_state[:top_hands]).to eq top_hands
        end

        it "sets end game flag to 'true'" do
          state = Game.initial_state(initial_players, small_blind: 0, big_blind: 0)

          new_state = Reducer.call state, type: :game_end,
                                          winner_ids: [1],
                                          top_hands: { 1 => double, 2 => double, 3 => double }
          expect(state[:game_ended]).to eq false
          expect(new_state[:game_ended]).to eq true
        end
      end
    end
  end
end
