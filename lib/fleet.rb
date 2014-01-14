require_relative 'setup'

class Fleet
  attr_reader :ships, :sunk

  def initialize
    @ships = []
    @hits = []
    @sunk = 0
  end

#  def mark_result(result)
    
  def shot_result(coord)
    if hit?(coord)
      @hits.push(coord)
      sunk = sunk?(coord)
      @sunk += 1 if sunk
      {result: 'H', coord: coord, sunk: sunk}
      
    else
      {result: 'm', coord: coord}
    end
  end

  def create_ship(ship_cfg)
    #p ship_cfg
    ship = ShipMaker.new(ship_cfg).ship

    if ship.coords.any? {|coord| occupied_coords.include? coord}
      raise BadShipCoordsException 

    else
      return ship
    end
  end

  def add_ship(ship, number=nil)
    unless number
      @ships.push(ship) 
    else
      @ships.insert(number - 1, ship)
    end
    return ship
  end

  def delete_ship(ship)
    @ships.delete(ship)
  end

  def occupied_coords
    @ships.collect {|ship| ship.coords}.flatten
  end
  
  def length
    @ships.length
  end

  def ship_number(ship)
    @ships.index(ship) + 1
  end

  def get_ship_by_number(number)
    @ships[number - 1]
  end

  private

  def hit?(coord)
    occupied_coords.include? coord
  end

  def sunk?(coord)
    ship = find_ship(coord)

    if ship.coords.all? {|coord| @hits.include? coord}
      ship.name
    else
      false
    end
  end

  def find_ship(coord)
    @ships.find { |ship| ship.coords.include? coord }
  end
end