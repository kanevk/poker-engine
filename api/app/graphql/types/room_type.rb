module Types
  class CardType < Types::BaseObject
    field :rank, String, null: false # TODO: move to enum
    field :color, String, null: false # TODO: move to enum
  end

  class PlayerType < Types::BaseObject
    OBJECT = Struct.new(:id, :name, :balance, :money_in_pot, :seat_number, :position, :avatar_url, :cards, :is_in_turn, keyword_init: true) do
      def initialize(**kwargs)
        super(kwargs.slice(*members))
      end
    end

    field :id, ID, null: false
    field :name, String, null: false
    field :balance, Integer, null: true
    field :money_in_pot, Integer, null: true
    field :seat_number, Int, null: true
    field :position, String, null: true # TODO: move to enum
    field :avatar_url, String, null: true
    field :cards, [CardType], null: true
    field :is_in_turn, Boolean, null: false
  end

  class GameType < Types::BaseObject
    field :id, ID, null: false

    field :version, ID, null: false

    field :current_player, PlayerType, null: true
    def current_player
      player = @object.state[:players][@context[:current_user].id]

      player ? resolve_player(player) : nil
    end

    field :current_stage, String, null: true
    def current_stage
      @object.state[:current_stage]
    end

    field :board_cards, [CardType], null: false
    def board_cards
      @object.state[:board]
    end

    field :game_ended, Boolean, null: false
    def game_ended
      @object.state[:game_ended]
    end

    field :big_blind, Integer, null: false
    def big_blind
      @object.state[:big_blind]
    end

    field :small_blind, Integer, null: false
    def small_blind
      @object.state[:small_blind]
    end

    field :pot, Integer, null: false
    def pot
      @object.state[:pot]
    end

    field :players, [PlayerType], null: true
    def players
      @object.state[:players].values.map { |player| player.merge(cards: []) }.map(&method(:resolve_player))
    end

    private

    def resolve_player(player)
      @context[:users_by_id] ||= User.find(@object.state[:players].keys).map { |u| [u.id, u] }.to_h

      user = @context[:users_by_id][player[:id]]
      fields = player.merge(
        name: user.name,
        seat_number: @context[:seat_number_per_player_id][player[:id]],
        is_in_turn: @object.state[:current_player_id] == player[:id]
      )

      Types::PlayerType::OBJECT.new(**fields)
    end
  end

  class RoomType < Types::BaseObject
    field :id, ID, null: false
    field :name, ID, null: false
    field :current_game, Types::GameType, null: false

    def current_game(*args)
      @context[:seat_number_per_player_id] = @object.seats.map.with_index.to_h

      @object.current_game
    end

  end
end
