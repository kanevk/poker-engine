require 'rails_helper'

RSpec.describe 'Authentication mutations', type: :mutations do
  it '#signin_user' do
    user = User.create!(name: 'name', password: 'pass', balance: 100)

    mutation = <<~GRAPHQL
      mutation ($username: String!, $password: String!) {
        signinUser(input: { username: $username, password: $password}) {
          userId
          token
        }
      }
    GRAPHQL

    response = graphql_execute(mutation, variables: {username: 'name', password: 'pass'}, context: {})

    expect(response[:errors]).to be_blank
    token = response.dig('data', 'signinUser', 'token')

    payload, _options = JWT.decode(token, Rails.application.secrets.secret_key_base.to_s)
    expect(payload).to include('user_id' => user.id)
  end
end
