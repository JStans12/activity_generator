require 'minitest/autorun'
require './src/activity_generator'

describe ActivityGenerator do
  before do
    @activity_generator = ActivityGenerator.new
  end

  def test_it_runs
    assert true
  end
end
