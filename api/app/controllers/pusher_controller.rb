class PusherController < ApplicationController

  include ActionController::HttpAuthentication::Token::ControllerMethods

  def auth
    current_user = user_by_token(params[:token])

    if current_user
      response = PUSHER.authenticate(params[:channel_name], params[:socket_id], {
        user_id: current_user.id
      })
      render json: response
    else
      render text: 'Forbidden', status: '403'
    end
  end

  def user_by_token(token)
    user_id = AuthToken.decode(token)[:user_id]

    raise GraphQL::ExecutionError.new("Wrong authentication token!") unless user_id

    User.find(user_id)
  end

end
