require_relative 'grid_view'

class Fleet
	attr_reader :hits, :sunk, :ships

	def initialize(ships)
		@ships = ships
		@hits = []
		@sunk = 0
	end

	def coords
		@ships.collect {|ship| ship.coords}.flatten(1)
	end

	def find_ship(coords)
		@ships.find { |ship| ship.coords.include? coords }
	end

	def number_of_ships
		@ships.length
	end

	def get_shot(coord)
		if hit?(coord)
			@hits.push(coord)
			sunk = sunk?(coord)
			{result: 'H', coord: coord, sunk: sunk}
			
		else
			{result: 'm', coord: coord}
		end
	end

	def hit?(coord)
		coords.include? coord
	end

	def sunk?(coord)
		ship = find_ship(coord)
		if ship.coords.all? {|coord| @hits.include? coord}
			@sunk += 1
			ship.name
		else
			false
		end
	end

end

class Attack_Grid
	attr_reader :sunk
	include GridView

	def initialize
		make_grid
		@sunk = []
	end

	def get_coord(coord)
		@grid[coord[0]][coord[1]]
	end

	def mark_result(result)
		coord = result[:coord]
		@grid[coord[0]][coord[1]] = result[:result]
		@sunk.push([result[:sunk], coord]) if !!result[:sunk]
	end

	def already_shot(coord)
		get_coord(coord) != ' '
	end
end