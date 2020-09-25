module GraphqlSupport
  def graphql_execute(query, variables: {}, context:)
    @session = {}
    context = { current_user: nil, session: @session }
    ::ApiSchema.execute(query, variables: variables, context: context).to_h
  end
end
