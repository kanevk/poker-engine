require 'rspec/expectations'

RSpec::Matchers.define :resolve_successfully do |*resolution_path|
  chain(:with) do |expected_partial_response|
    @expected_partial_response = expected_partial_response
  end

  match do |actual_response|
    if failed?(actual_response)
      @actual = actual_response
      @expected = @expected_partial_response

      return false
    end

    @actual = actual_response.dig("data", *resolution_path)
    @expected = @expected_partial_response

    values_match? @expected, @actual
  end

  def failed?(actual_response)
    actual_response["error"] || actual_response["errors"]
  end

  diffable
  attr_reader :actual, :expected
end
