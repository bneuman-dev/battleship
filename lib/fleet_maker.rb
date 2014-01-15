require_relative 'ship_maker'

# TODO retire the Fleet Maker
module Fleet_Maker
	attr_reader :fleet

	def initialize_fleet
		@fleet = []
	end

	def coords
		@fleet.collect {|ship| ship.coords}.flatten(1)
	end

	def create_new_ship(ship_cfg, index=nil)
		Ship_Maker.new(ship_cfg, self.coords).ship
	end

	def add_ship(ship, index=nil)
		unless index
			@fleet.push(ship) 
		else
			@fleet.insert(index, ship)
		end
		return ship
	end

	def delete_ship(ship)
		@fleet.delete(ship)
	end
end
