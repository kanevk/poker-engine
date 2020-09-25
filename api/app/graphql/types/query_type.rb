module Types
  class QueryType < Types::BaseObject
    field :is_authenticated, Boolean, null: false
    def is_authenticated
      !!context[:current_user]
    end

    field :get_room, Types::RoomType, null: false do
      argument :id, ID, required: true, default_value: false
    end

    def get_room(id:)
      Room.find(id)
    end

    field :rooms, [Types::RoomType], null: false

    def rooms
      Room.all
    end
  end
end
