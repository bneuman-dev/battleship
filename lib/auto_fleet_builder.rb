require_relative 'setup'

class AutoFleetBuilder
  attr_reader :fleet

  def initialize(cfg)
    @config = parse_config(cfg)
    @fleet = Fleet.new
  end

  def parse_config(cfg)
    config = cfg.inject(Array.new) do |config, ship| 
      ship[:quantity].times { config.push(ship) }
      config
    end

    config.shuffle
  end

  def make_fleet
    @config.each { |ship| place_ship(ship) }
  end

  def place_ship(ship_cfg)
    length = ship_cfg[:length]  

    coord1, coord2 = make_coords(length)
    ship_config = {name: ship_cfg[:name], length: length, coord1: coord1, coord2: coord2}
    
    begin
      ship = @fleet.create_ship(ship_config)

    rescue InvalidShipException, BadShipCoordsException
      place_ship(ship_cfg)

    else
      @fleet.add_ship(ship)
    end
  end

  def make_coords(length)
    coord1 = rand(80)
    coord2 = calculate_second_coord(coord1, length)
    [coord1, coord2]
  end

  def calculate_second_coord(coord1, length)
    orientation = rand(1) == 0 ? ROWS : COLUMNS
    range = orientation.find { |line| line.include? coord1 }
    coord1_index = range.index(coord1)
    coord2_index = rand(1) == 0 ? coord1_index + (length - 1) : coord1_index - (length - 1)
    range[coord2_index]
  end
end