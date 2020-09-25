require 'rails_helper'

RSpec.describe 'Room query', type: :queries do
  it do
    query = <<~GRAPHQL
      query ($roomId: ID!) {
        getRoom(id: $roomId) {
          id
          currentGame {
            id
            version
            currentPlayerId
            currentStage
            gameEnded
            smallBlind
            bigBlind
            pot
            boardCards { rank color }
            players {
              id
              name
              avatarUrl
              balance
              position
              seatNumber
              cards { rank color }
            }
          }
        }
      }
    GRAPHQL

    user = User.create!(name: 'bob', balance: 100)
    another_user = User.create!(name: 'maria', balance: 200)

    players = [
      { id: user.id, balance: 100 },
      { id: another_user.id, balance: 200 },
    ]

    room = Room.create!(name: 'name', small_blind: 5, big_blind: 10)

    game_state = PokerEngine::Game.start(players, small_blind: room.small_blind,
                                                           big_blind: room.big_blind,
                                                           deck_seed: rand(1..1_000))
    game = Game.create!(state: game_state, room: room)
    room.update!(current_game: game, seats: [user.id, another_user.id])

    response = graphql_execute(query, variables: { 'roomId' => room.id }, context: {})

    game.reload

    expect(response).to resolve_successfully('getRoom').with({
      'id' => room.id.to_s,
      'currentGame' => {
        'id' => game.id.to_s,
        'version' => game.version,
        'currentPlayerId' => '1',
        'currentStage' => 'preflop',
        'gameEnded' => false,
        'smallBlind' => 5.0,
        'bigBlind' => 10.0,
        'pot' => 15.0,
        'boardCards' => [],
        'players' => contain_exactly(
          {
            'id' => user.id.to_s,
            'name' => 'bob',
            'avatarUrl' => nil,
            'balance' => 95.0,
            'position' => 'SB',
            'seatNumber' => 0,
            'cards' => game_state[:players][user.id][:cards].map { |c| { 'rank' => c.rank, 'color' => c.color.to_s } },
          },
          {
            'id' => another_user.id.to_s,
            'name' => 'maria',
            'avatarUrl' => nil,
            'balance' => 190.0,
            'position' => 'BB',
            'seatNumber' => 1,
            'cards' => game_state[:players][another_user.id][:cards].map { |c| { 'rank' => c.rank, 'color' => c.color.to_s } },
          },
        )
      }
    })
  end
end
