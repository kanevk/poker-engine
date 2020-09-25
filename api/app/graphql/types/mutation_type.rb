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
    argument :room_id, ID, required: true
    # TOOD: Turn to Enum
    argument :move, String, required: true
    argument :bet, String, required: false
    argument :x_player_id, String, required: false if Rails.env.development?

    field :success, Boolean, null: false

    def resolve(room_id:, move:, bet: nil, x_player_id: nil)
      room = Room.find(room_id)
      state = room.current_game.state

      player_id = (x_player_id || @context[:current_user].id).to_i

      if state[:current_player_id] != player_id
        raise "Wrong player in turn #{player_id}. In turn is #{state[:current_player_id]}"
      end

      action = { player_id: player_id, type: move.to_sym, bet: bet.to_i }

      new_state = PokerEngine::Game.next(state, action) { |*args| Rails.logger.info("^^^^^^ #{args}") }
      room.current_game.update!(state: new_state)

      ApiSchema.subscriptions.trigger(:get_room, { room_id: room_id }, room.reload)
      { success: true }
    end
  end

  class MutationType < Types::BaseObject
    field :signin_user, mutation: SigninUserMutation

    field :make_move, mutation: MakeMove
  end
end
