class Types::GetRoomType < Subscriptions::BaseSubscription
  payload_type Types::RoomType
  argument :room_id, ID, required: true

  def subscribe(room_id:)
    Room.find(room_id)
  end

  def update(room_id:)
    Rails.logger.info("****** #{object}")
    Room.find(room_id)
  end

end

class Types::SubscriptionType < GraphQL::Schema::Object
  extend GraphQL::Subscriptions::SubscriptionRoot

  field :get_room, subscription: Types::GetRoomType
end
