require_relative 'setup'

class Fleet_Factory
  attr_reader :fleet

  def initialize(builder)
    builder = builder.new(ships_conf)
    builder.make_fleet
    @fleet = builder.fleet
  end
end