module Types
  class SigninUserMutation < Mutations::BaseMutation
    argument :username, String, required: true
    argument :password, String, required: true

    field :user_id, ID, null: true
    field :token, String, null: true

    def resolve(username:, password:)
      user = User.find_by name: username

      return { user_id: nil } unless user
      return { user_id: nil } unless user.authenticate(password)

      token = ::AuthToken.encode(user_id: user.id)

      { user_id: user.id, token: token }
    end
  end

  class MakeMove < Mutations::BaseMutation
    argument :game_version, ID, required: true
    # TOOD: Turn to Enum
    argument :move, String, required: true
    argument :bet, Integer, required: false
    argument :x_player_id, ID, required: false if Rails.env.development?

    field :success, Boolean, null: false

    def resolve(game_version:, move:, bet: nil, x_player_id: nil)
      # TODO: validate current player on move
      player_id = (x_player_id || @context[:current_user].id)&.to_i
      game = Gameplay.make_move(game_version, player_id: player_id, move: move.to_sym, bet: bet&.to_i)

      ApiSchema.subscriptions.trigger(:get_room, { room_id: game.room_id }, nil)
      { success: true }
    end
  end

  class MutationType < Types::BaseObject
    field :signin_user, mutation: SigninUserMutation

    field :make_move, mutation: MakeMove
  end
end
