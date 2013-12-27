require_relative 'coord'
require_relative 'board'

class Ships_Maker
	attr_reader :ships

	def initialize(cfg)
		@config = parse_config(cfg)
		@ships = Ships.new
		create_ships
	end

	def parse_config(cfg)
		config = cfg.inject(Array.new) do |config, ship| 
			ship[:quantity].times { config.push(ship) }
			config
		end

		config.shuffle
	end

	def create_ships
		@config.each { |ship| make_a_ship(ship)}
	end

	def make_a_ship(ship)
	
		length = ship[:length]
		invalid = true

		while invalid

			coord1_x = rand(9) 
			coord1_y = rand(9)
			direction = rand(3)
			ship_config = {name: ship[:name], length: length, coord1: [coord1_x, coord1_y]}

			case direction

			when 0
				ship_config[:coord2] = [coord1_x + (length - 1), coord1_y]

			when 1
				ship_config[:coord2] = [coord1_x, coord1_y + (length - 1)]

			when 2
				ship_config[:coord2] = [coord1_x - (length - 1), coord1_y]

			when 3
				ship_config[:coord2] = [coord2_x, coord1_y - (length - 1)]
			end
			
			begin
				@ships.create_new_ship(ship_config)

			rescue InvalidShipException
				invalid = true

			rescue BadShipCoordsException
				invalid = true

			else
				invalid = false
			end
		end

	end
end

class Ships_Placer
	include CoordTranslator
	include GridView

	attr_reader :ships
	def initialize(ships_cfg)
		make_grid
		@ships_cfg = ships_cfg
		@ships = Ships.new
		@ships_added = []
	end

	def place
		not_done = true

		while not_done
			instructions

			input = gets.chomp

			if input.downcase.include? 'done'
				if @ships_cfg.all? {|ship| ship[:quantity] == 0}
					not_done = false

				else
					puts "You are not done yet!"
				end
			
			elsif @ships_cfg.any? { |ship_cfg| (input.downcase.include? ship_cfg[:name].downcase) && ship_cfg[:quantity] > 0}
				add_ship(input)

			elsif input =~ /\d\s[a-jA-J]\d{1,2}\s[a-jA-J]\d{1,2}/
				edit_ship(input)

			else
				puts "I don't understand your input"
			end
		end
	end

	def instructions
		puts "You will need the following ships: "
		@ships_cfg.each do |ship|
			puts "#{ship[:quantity]} of #{ship[:name]} of length #{ship[:length]}" if ship[:quantity] > 0
		end

		puts "Place them with the following syntax: ship-name start-coord end-coord"
		puts "E.g., destroyer a6 b6"
		puts "      carrier c3 c7"

		puts "If you want to move a ship after placing it, use the following syntax: ship-number new-start-coord new-end-coord "
		puts "E.g., 1 a6 c6"
		puts "      4 f4 f8"

		puts "When done, type 'done'"

		view_grid
	end

	def add_ship(input)

		name, coord1, coord2 = input.split(' ')
		ship_cfg = @ships_cfg.find { |ship| ship[:name] == name.downcase.capitalize }

=begin
		while !ship_cfg
			puts "Ship name is invalid"
			name, coord1, coord2 = gets.chomp.split(' ')
			ship_cfg = @ships_cfg.find { |ship| ship[:name] == name.downcase.capitalize }
		end
=end

		ship_cfg[:coord1] = to_coord(coord1)
		ship_cfg[:coord2] = to_coord(coord2)
	  place_ship(ship_cfg)
	
	  ship_cfg[:quantity] -= 1
		ship = @ships.ships[-1]		
		index = @ships.ships.index(ship)
		mark_coords(ship.coords, index + 1)
	end

	def edit_ship(input)
		index, coord1, coord2 = input.split(' ')
		index = index.to_i
		ship_to_edit = @ships.delete_ship(@ships.ships[index - 1])

		while !ship_to_edit
			index, coord1, coord2 = gets.chomp.split(' ')
			index = index.to_i
			ship_to_edit = @ships.delete_ship(@ships.ships[index - 1])
		end			

		edited_ship_cfg = {name: ship_to_edit.name,
				        length: ship_to_edit.length,
				        coord1: to_coord(coord1),
				        coord2: to_coord(coord2),
				      }

		place_ship(edited_ship_cfg, index - 1)
		edited_ship = @ships.ships[index - 1]
		mark_coords(ship_to_edit.coords, ' ')
		mark_coords(edited_ship.coords, index)
	end

	def place_ship(ship_cfg, index = nil)
		not_added_yet = true

		while not_added_yet
			begin
				ship = @ships.create_new_ship(ship_cfg, index) 

			rescue InvalidShipException
				puts "Those coordinates are invalid. Re-enter coords: e.g., a6 c6."
				coord1, coord2 = gets.chomp.split(' ')
				ship_cfg[:coord1] = to_coord(coord1)
				ship_cfg[:coord2] = to_coord(coord2)

			rescue BadShipCoordsException
				puts "A ship already exists at those coordinates. Re-enter coords: e.g., a6 c6."
				coord1, coord2 = gets.chomp.split(' ')
				ship_cfg[:coord1] = to_coord(coord1)
				ship_cfg[:coord2] = to_coord(coord2)

			else
				not_added_yet = false
			end
		end
	end

	def mark_coords(coords, marking)
		
		coords.each do |coord|
			grid[coord[0]][coord[1]] = marking
		end
	end

end

class Ship_Adder
	attr_reader :ship

	def initialize(config_hash, coords)
		@config_hash = config_hash
		raise InvalidShipException if !ship_valid?
		@board_coords = coords
		@ship_coords = make_coords(config_hash)
		@config_hash[:coords] = @ship_coords

		
		raise BadShipCoordsException if check_bad_coords
	
		@ship = Ship.new(config_hash)
		
	end

	def ship_valid?
		Ship_Validator.new(@config_hash).valid?
	end

	def check_bad_coords
		@ship_coords.any? {|ship_coord| @board_coords.include? ship_coord}
	end

	def make_coords(config_hash)
		coord1, coord2 = [config_hash[:coord1], config_hash[:coord2]].sort

		if coord1[0] != coord2[0]
			(coord1[0]..coord2[0]).collect {|x| [x, coord1[1]]}.sort

		elsif coord1[1] != coord2[1]
			(coord1[1]..coord2[1]).collect {|y| [coord1[0], y]}.sort

		else
			[coord1]
		end
	end
end


class Ship_Validator
	def initialize(config_hash)
		@valid = validate(config_hash)
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