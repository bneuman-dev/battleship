require_relative 'fleet_maker'
require_relative 'grid_view'
require_relative 'coord_translator'
require_relative 'exceptions'

class Human_Fleet_Builder
	include CoordTranslator
	include GridView
	include Fleet_Maker

	def initialize(ships_cfg)
		make_grid
		initialize_fleet
		@ships_cfg = ships_cfg
	end

	def number_of_ships
		@ships_cfg.inject(number = 0) { |number, ship| number += ship[:quantity]}
	end

	def make_fleet
		instructions
		prompt
	end

	def instructions
		
		puts "To add a ship, type add [ship_name]. E.g.,"
		puts "   add destroyer"
		puts "   add carrier"

		puts "To edit a ship, type edit [ship_number]. E.g.,"
		puts "   edit 2"

		puts "When done, type 'done'."

		puts "Type 'instructions' to view instructions again."
		view_grid
		needed_ships
	end

	def needed_ships
		puts "You need the following ships: "
		@ships_cfg.each do |ship|
			puts "#{ship[:quantity]} of #{ship[:name]} of length #{ship[:length]}" if ship[:quantity] > 0
		end
	end

	def prompt
		puts 'Options:'
		puts '	add [ship_name]' 
		puts '  edit [ship_number]'
		puts '  instructions'
		puts '  done'

		input = gets.chomp.downcase

		if input.include? 'done'
			parse_done
		
		elsif input.include? 'add'
			parse_add(input)
			prompt

		elsif input.include? 'edit'
			parse_edit(input)
			prompt

		elsif input.include? 'instructions'
			instructions
			prompt

		else
			puts "I don't understand your input"
			prompt
		end
	
	end

	def done?
		@ships_cfg.all? {|ship| ship[:quantity] == 0}
	end

	def parse_done
		unless done?
			puts "You are not done yet!"
			prompt

		else
			puts "Fleet created."
		end
	end

	def parse_add(input)
		ship_name = input.gsub('add', '').gsub(' ', '')
		ship_cfg = @ships_cfg.find { |ship| ship[:name].downcase == ship_name }

		if ship_cfg == nil
			puts "Can't find ship with name #{ship_name}"

		elsif ship_cfg[:quantity] == 0
			puts "You have already added all your #{ship_cfg[:name]}s"

		else
			name = make_a_ship(ship_cfg)
			view_grid
			needed_ships
		end
	end

	def parse_edit(input)
		ship_number = input.gsub('edit', '').gsub(' ', '')

		if ! ((1..@fleet.length).to_a.include? ship_number.to_i)
			puts "Can't find a #{ship_number} to edit"
		
		else
			edit_ship(ship_number.to_i)
			view_grid
			needed_ships
		end
	end

	def make_a_ship(ship_cfg)
		puts "Adding ship #{ship_cfg[:name]} of length #{ship_cfg[:length]}."
		puts "Enter start and end coordinates."
		puts "E.g., a6 d6"
	  ship = place_ship(ship_cfg)
		index = @fleet.index(ship)
		mark_coords(ship.coords, index + 1)
		ship_cfg[:quantity] -= 1
		return ship.name
	end

	def edit_ship(index)
	
		ship_to_edit = delete_ship(@fleet[index - 1])
		puts "Editing #{ship_to_edit[:name]} of length #{ship_to_edit[:length]}."
		puts "Enter new start and end coordinates."
		mark_coords(ship_to_edit.coords, ' ')
		ship_cfg = {name: ship_to_edit.name, length: ship_to_edit.length}
		edited_ship = place_ship(ship_cfg, index - 1)	
		mark_coords(edited_ship.coords, index)
		return edited_ship.name
	end

	def place_ship(ship_cfg, index = nil)
		ship_cfg[:coord1], ship_cfg[:coord2] = get_coordinates

		begin
			ship = create_new_ship(ship_cfg, index) 

		rescue InvalidShipException
			puts "Those coordinates are invalid. Re-enter coords."
			place_ship(ship_cfg, index)
			
		rescue BadShipCoordsException
			puts "A ship already exists at those coordinates. Re-enter coords: e.g., a6 c6."
			place_ship(ship_cfg, index)

		else
			add_ship(ship)
		end
	end

	def get_coordinates
		input = gets.chomp
		coords = input.scan(/[A-J|a-j]10|[A-J|a-j][1-9]/)

		if coords.length != 2
			puts "Invalid input"
			get_coordinates

		else
			return [to_coord(coords[0]), to_coord(coords[1])]
		end
	end


	def mark_coords(coords, marking)
		
		coords.each do |coord|
			grid[coord[0]][coord[1]] = marking
		end
	end
end