require_relative 'setup'

Ship = Struct.new(:name, :length, :coords)

class Ship_Maker
  attr_reader :ship

  def initialize(ship_cfg)
    @ship_cfg = ship_cfg
    @coord1 = ship_cfg[:coord1]
    @coord2 = ship_cfg[:coord2]
    @length = ship_cfg[:length]

    raise InvalidShipException if !valid?
    coords = make_coords
    @ship = Ship.new(@ship_cfg[:name], @ship_cfg[:length], coords)
  end

  def make_coords

    coord1x, coord1y = @coord1
    coord2x, coord2y = @coord2

    if coord1x < coord2x
      (coord1x..coord2x).collect {|x| [x, coord1y]}

    elsif coord2x < coord1x
      (coord2x..coord1x).collect {|x| [x, coord1y]}

    elsif coord1y < coord2y
      (coord1y..coord2y).collect {|y| [coord1x, y]}

    elsif coord2y < coord1y
      (coord2y..coord1y).collect {|y| [coord1x, y]}

    else
      [@coord1]
    end
  end

  def valid?
    return false if [@coord1, @coord2].flatten.any? {|num| num < 0 || num > 9 || !(num.is_a? Integer) }

    if get_length(@coord1, @coord2) != @length
      return false

    else
      return true
    end
  end

  private

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