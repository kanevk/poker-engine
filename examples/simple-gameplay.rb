#!/usr/bin/env ruby

require 'bundler/setup'

Bundler.require :default, :development

RENDER_TIMEOUT = 1 # seconds

players = [
  { id: 0, balance: 1000 },
  { id: 1, balance: 900 },
  { id: 2, balance: 500 },
]

def event_handler(action, state)
  draw state, action
  sleep RENDER_TIMEOUT
end

def draw_border(delimiter, title = '')
  title.center 80, delimiter
end

def player_name(id)
  "Player#{id}".yellow
end

def draw(state, action)
  system 'clear'
  puts <<~TEMPLATE.yellow
    #{draw_border '>'}
    POT: #{state[:pot]}
    BOARD: #{state[:board].map(&:to_s).join(', ')}
    #{draw_border '<'}
  TEMPLATE

  state[:players].sort_by { |id, _| id }.each do |id, player|
    player_box = <<~TEMPLATE
      #{draw_border '=', player_name(id)}
      POSITION: #{player[:position]}
      BALANCE: #{player[:balance]}
      CARDS: #{player[:cards].map(&:to_s).join(', ')}
      Money in the pot: #{player[:money_in_pot]}
      #{draw_border '='}
    TEMPLATE

    puts player[:active] ? player_box : player_box.red
  end

  case action[:type]
  when :move_request
    print "#{player_name(action[:player_id])} make a move [move, bet] -> "
    move, bet = gets.strip.split("\s")

    PokerEngine::Game.next state,
                           type: move.to_sym,
                           bet: bet&.to_i,
                           player_id: action[:player_id],
                           &method(:event_handler)
  when :game_end
    winners = state[:winner_ids].map(&method(:player_name))
    winners_label = winners.one? ? "Winner #{winners.first}" : "Winners #{winners.join(', ')}"

    players_hands =
      state[:top_hands]
      .sort_by { |_, hand| hand }
      .map do |id, hand|
        "#{player_name(id)} with hand #{hand.cards} #{hand.level.name}\n"
      end
      .join

    puts <<~TEMPLATE
      #{draw_border '#', winners_label}
      #{players_hands}
      #{draw_border '#'}
    TEMPLATE
  end
end

PokerEngine::Game.start players,
                        small_blind: 10,
                        big_blind: 20,
                        deck_seed: rand(1000),
                        &method(:event_handler)
