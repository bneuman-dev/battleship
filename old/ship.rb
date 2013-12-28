require_relative 'coord'
require_relative 'board'








Ship = Struct.new(:name, :length, :coords)

class Ship_Maker
	attr_reader :ship

	def initialize(ship_cfg, occupied_coords)
		@ship_cfg = ship_cfg
		@occupied_coords = coords
		ship_coords = get_coords
		@ship = Ship.new(@config_hash[:name], @config_hash[:length], ship_coords)
	end

	def validate_ship
		raise InvalidShipException if !(Ship_Validator.new(@config_hash).valid?)
	end

	def get_coords
		ship_coords = Ship_Coords.new(@ship_cfg[:coord1], @ship_cfg[:coord2], @occupied_coords)
		raise BadShipCoordsException if !(ship_coords.valid?)
		ship_coords.ship_coords
	end
end

class Ship_Coords

	attr_reader :ship_coords
	def initialize(ship_coord1, ship_coord2, occupied_coords)
		@ship_coords = make_coords(ship_coord1, ship_coord2)
		@occupied_coords = occupied_coords
	end
		
	def valid?
		check_bad_coords
	end

	def check_bad_coords
		@ship_coords.any? { |ship_coord| @occupied_coords.include? ship_coord }
	end

	def make_coords(coord1, coord2)

		if coord1[0] != coord2[0]
			(coord1[0]..coord2[0]).collect {|x| [x, coord1[1]]}.sort

		elsif coord1[1] != coord2[1]
			(coord1[1]..coord2[1]).collect {|y| [coord1[0], y]}.sort

		else
			[coord1]
		end
	end

class Ship_Validator
	def initialize(ship_cfg)
		@valid = validate(ship_cfg)
	end

	def valid?
		@valid
	end

	def validate(config_hash)
		coord1 = config_hash[:coord1]
		coord2 = config_hash[:coord2]
		length = config_hash[:length]

		return false if [coord1[0], coord1[1], coord2[0], coord2[1]].any? {|num| num < 0 || num > 9 || !(num.is_a? Integer) }

		if get_length(coord1, coord2) != length
			return false

		else
			return true
		end
	end

	def get_length(coord1, coord2)
		length_x = (coord1[0] - coord2[0]).abs
		length_y = (coord1[1] - coord2[1]).abs

		if length_x > 0 && length_y > 0
			false

		else
			length_x > 0 ? (length_x + 1) : (length_y + 1)
		end
	end
end