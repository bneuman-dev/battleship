require_relative 'fleet_maker'
require_relative 'exceptions'

class Auto_Fleet_Builder
	include Fleet_Maker
	attr_reader :config
	def initialize(cfg)
		@config = parse_config(cfg)
		initialize_fleet
	end

	def parse_config(cfg)
		config = cfg.inject(Array.new) do |config, ship| 
			ship[:quantity].times { config.push(ship) }
			config
		end

		config.shuffle
	end

	def make_fleet
		@config.each { |ship| make_a_ship(ship)}
	end

	def make_a_ship(ship_cfg)
		length = ship_cfg[:length]	

		coord1, coord2 = make_coords(length)
		ship_config = {name: ship_cfg[:name], length: length, coord1: coord1, coord2: coord2}
		
		begin
			ship = create_new_ship(ship_config)

		rescue InvalidShipException, BadShipCoordsException
			make_a_ship(ship_cfg)

		else
			add_ship(ship)
		end
	end

	def make_coords(length)
		coord1 = [rand(9), rand(9)]
		coord2 = calculate_second_coord(coord1, length)
		[coord1, coord2]
	end

	def calculate_second_coord(coord1, length)
		direction = rand(3)
	
		case direction

		when 0
			[coord1[0] + (length - 1), coord1[1]]

		when 1
			[coord1[0], coord1[1] + (length - 1)]

		when 2
			[coord1[0] - (length - 1), coord1[1]]

		when 3
			[coord1[0], coord1[1] - (length - 1)]
		end
	end

end