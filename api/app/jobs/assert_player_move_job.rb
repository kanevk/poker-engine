class AssertPlayerMoveJob
  include Sidekiq::Worker

   sidekiq_options retry: false
  # queue_as :default

  def perform(kwargs = {})
    kwargs.symbolize_keys!

    game_version = kwargs.fetch(:game_version)
    player_id = kwargs.fetch(:player_id)

    begin
      game = Gameplay.make_move(game_version, player_id: player_id, move: :fold)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.info("Game state dismatch")
      return
    end

    ApiSchema.subscriptions.trigger(:get_room, { room_id: game.room_id }, nil)
  end
end
