# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

users =
  %w(bob player42 game_over u-r-going-down bOOb3 next_turn hangover night-n-day).map do |name|
    User.create!(name: name, password: '1', balance: rand(100.00..2000.0))
  end


%w(heaven ocean river cotton salt sugar blue red).each do |room_name|
  players = users.shuffle[0..5].map { |u| {id: u.id, balance: u.balance} }

  room = Room.create!(name: room_name, small_blind: 5, big_blind: 10, seats: players.map { |pl| pl[:id] } )

  game_state = PokerEngine::Game.start(players, small_blind: room.small_blind,
                                                big_blind: room.big_blind,
                                                deck_seed: 1)
  game = Game.create!(state: game_state, room: room)
  room.update!(current_game: game)
end
