require_relative 'exceptions'

Ship = Struct.new(:name, :length, :coords)

class Ship_Maker
	attr_reader :ship

	def initialize(ship_cfg, occupied_coords)
		@ship_cfg = ship_cfg
		@occupied_coords = occupied_coords
		validate_ship
		coords = set_coords
		@ship = Ship.new(@ship_cfg[:name], @ship_cfg[:length], coords)
	end

	def set_coords
		coords = make_coords(@ship_cfg[:coord1], @ship_cfg[:coord2])
		if bad_coords? (coords)
			raise BadShipCoordsException 

		else
			return coords
		end
	end

	def bad_coords? (coords)
		coords.any? { |ship_coord| @occupied_coords.include? ship_coord }
	end

	def make_coords(coord1, coord2)

		coord1a, coord1b = coord1
		coord2a, coord2b = coord2

		if coord1a < coord2a
			(coord1a..coord2a).collect {|x| [x, coord1b]}

		elsif coord2a < coord1a
			(coord2a..coord1a).collect {|x| [x, coord1b]}

		elsif coord1b < coord2b
			(coord1b..coord2b).collect {|y| [coord1a, y]}

		elsif coord2b < coord1b
			(coord2b..coord1b).collect {|y| [coord1a, y]}

		else
			[coord1]
		end
	end

	def validate_ship
		raise InvalidShipException if !(Ship_Validator.new(@ship_cfg).valid?)
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