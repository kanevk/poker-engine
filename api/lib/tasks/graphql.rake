require "graphql/rake_task"

namespace :graphql do
  task dump_schema: :environment do
    require "graphql/rake_task"

    GraphQL::RakeTask.new(
      load_schema: ->(_task) {
        require File.expand_path("../../app/graphql/api_schema", __dir__)
        ApiSchema
      },
      directory: "./config"
    )
    Rake::Task["graphql:schema:idl"].invoke
  end
end
