class Board
	attr_accessor :board
	def initialize
		@board = make_board
		@letters = {a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9}
	end

	def place_ship(coord1, coord2, length)
		
		place_ship_at_coords(coord1, coord2) if check_ship_placement(coord1, coord2, length) == true
	end

	def place_ship_at_coords(coord1, coord2)
		(coord1[0]..coord2[0]).inject(Hash.new) do |coords, coord|
				coords.push([coord, ])
			end
	end

	def check_ship_placement(coord1, coord2, length)
		coord1 = translate_coord(coord1)
		coord2 = translate_coord(coord2)
		distance = get_distance(coord1, coord2)

		if distance == false || distance != length - 1
			return false

		else
			return true
		end
	end

	private

	def get_distance(coord1, coord2)
		distance_x = (coord1[0] - coord2[0]).abs
		distance_y = (coord1[1] - coord2[1]).abs
		return false if distance_x > 0 && distance_y > 0
		return distance_x if distance_x > 0
		return distance_y if distance_y > 0
		return 0 if distance_x == 0 && distance_y == 0
	end

	def make_board
		Array.new(10, Array.new(10, 0))
	end

	def translate_letter(letter)
		@letters[letter.downcase.to_sym]
	end

	def translate_coord(coord)
		[translate_letter(coord[0]), coord[1].to_i]
	end

	def get_coordinate(coordinate)
		@board[translate(coordinate[0])][coordinate[1]]
	end
end

class Ship
	attr_reader :length
	def initialize(coord1, coord2, length)
		@coord1 = coord1
		@coord2 = coord2
		@length = length
		@t_coord1 = translate_coord(@coord1)
		@t_coord2 = translate_coord(@coord2)
		@distance_x = get_distance_x
		@distance_y = get_distance_y
	end

	def valid?
		return false if @distance_x > 0 && @distance_y > 0
		return false if @length != get_length
		return true
	end

	def coordinates
		return @t_coord1 if @distance_x == 0 && @distance_y == 0
		
	
	private
		def get_distance_x
			(@t_coord1[0] - @t_coord2[0]).abs
		end

		def get_distance_y
			(@t_coord1[1] - @t_coord2[1]).abs
		end

		def get_length
			if @distance_x > 0
				@distance_x + 1

			elsif @distance_y > 0
				@distance_y + 1

			else
				1
			end
		end

		def letters
			{a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9}
		end

		def translate_letter(letter)
			letters[letter.downcase.to_sym]
		end

		def translate_coord(coord)
			[translate_letter(coord[0]), coord[1].to_i]
		end
end


class Carrier < Ship
	def initialize(coord1, coord2)
		super(coord1, coord2, 5)
	end
end


class Battleship < Ship
	def initialize(coord1, coord2)
		super(coord1, coord2, 4)
	end
end

class Cruiser < Ship
	def initialize(coord1, coord2)
		super(coord1, coord2, 3)
	end
end

class Destroyer < Ship
	def initialize(coord1, coord2)
		super(coord1, coord2, 2)
	end
end

class Submarine < Ship
	def initialize(coord1, coord2)
		super(coord1, coord2, 1)
	end
end


