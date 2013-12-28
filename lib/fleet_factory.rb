require_relative 'boards'
require_relative 'auto_fleet_builder'
require_relative 'human_fleet_builder'

class Fleet_Factory
	attr_reader :fleet

	def initialize(builder, cfg)
		builder = builder.new(cfg)
		builder.make_fleet
		@fleet = Fleet.new(builder.fleet)
	end
end