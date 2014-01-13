require_relative 'setup'

class HumanFleetBuilder

  attr_reader :fleet
  def initialize(ships_cfg)
    @grid = Grid.new
    @fleet = Fleet.new
    @ships_cfg = ships_cfg
  end

  def number_of_ships
    @ships_cfg.inject(0) { |number, ship| number += ship[:quantity]}
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
    @grid.view_grid
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
    puts '  add [ship_name]' 
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

  def parse_done
    unless done?
      puts "You are not done yet!"
      prompt

    else
      puts "Fleet created."
    end
  end

  def done?
    @ships_cfg.all? {|ship| ship[:quantity] == 0}
  end

  def parse_add(input)
    ship_name = input.gsub('add', '').gsub(' ', '')
    ship_cfg = @ships_cfg.find { |ship| ship[:name].downcase == ship_name }

    if ship_cfg == nil
      puts "Can't find ship with name #{ship_name}"

    elsif ship_cfg[:quantity] == 0
      puts "You have already added all your #{ship_cfg[:name]}s"

    else
      new_ship(ship_cfg)
      @grid.view_grid
      needed_ships
    end
  end

  def parse_edit(input)
    ship_number = input.gsub('edit', '').gsub(' ', '')

    if ! ((1..@fleet.length).to_a.include? ship_number.to_i)
      puts "Can't find a #{ship_number} to edit"
    
    else
      edit_ship(ship_number.to_i)
      @grid.view_grid
      needed_ships
    end
  end

  def new_ship(ship_cfg)
    puts "Adding ship #{ship_cfg[:name]} of length #{ship_cfg[:length]}."
    puts "Enter start and end coordinates."
    puts "E.g., a6 d6"
    ship = place_ship(ship_cfg)
    number = @fleet.ship_number(ship)
    @grid.mark_coords(ship.coords, number)
    ship_cfg[:quantity] -= 1
  end

  def edit_ship(number)
    ship_to_edit = @fleet.delete_ship(@fleet.get_ship_by_number(number))
    puts "Editing #{ship_to_edit[:name]} of length #{ship_to_edit[:length]}."
    puts "Enter new start and end coordinates."
    @grid.mark_coords(ship_to_edit.coords, ' ')
    ship_cfg = {name: ship_to_edit.name, length: ship_to_edit.length}
    edited_ship = place_ship(ship_cfg, number) 
    @grid.mark_coords(edited_ship.coords, number)
  end

  def place_ship(ship_cfg, number = nil)
    coord1, coord2 = get_coordinates
    p coord1
    p coord2
    begin
      ship = @fleet.create_ship({name: ship_cfg[:name], length: ship_cfg[:length], coord1: coord1, coord2: coord2}) 

    rescue InvalidShipException => e
      puts "#{e.message}. Re-enter coords."
      place_ship(ship_cfg, number)
      
    rescue BadShipCoordsException
      puts "A ship already exists at those coordinates. Re-enter coords: e.g., a6 c6."
      place_ship(ship_cfg, number)

    else
      @fleet.add_ship(ship, number)
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
end