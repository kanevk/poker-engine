module Gameplay
 def self.make_move(game_version, player_id:, move:, bet: nil)
    game = Game.lock("FOR UPDATE NOWAIT").find_by!(version: game_version)
    new_state = PokerEngine::Game.next(game.state, player_id: game.state[:current_player_id],
                                                   type: move,
                                                   bet: bet)
    game.update_state(new_state)

    if new_state[:last_action][:type] == :move_request
      AssertPlayerMoveJob.perform_in(15.seconds, game_version: game.version, player_id: new_state[:last_action][:player_id])
    end

    game
 end
end
