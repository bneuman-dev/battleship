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

    coord1a, coord1b = @coord1
    coord2a, coord2b = @coord2

    if coord1a < coord2a
      (coord1a..coord2a).collect {|a| [a, coord1b]}

    elsif coord2a < coord1a
      (coord2a..coord1a).collect {|a| [a, coord1b]}

    elsif coord1b < coord2b
      (coord1b..coord2b).collect {|b| [coord1a, b]}

    elsif coord2b < coord1b
      (coord2b..coord1b).collect {|b| [coord1a, b]}

    else
      [@coord1]
    end
  end

  def valid?
    return false if [@coord1, @coord2].flatten.any? {|num| num < 0 || num > 9 || !(num.is_a? Integer) }

    check_length
  end

  private

  def check_length
    get_length(@coord1, @coord2) == @length
  end

  def get_length(coord1, coord2)
    length_a = (coord1[0] - coord2[0]).abs
    length_b = (coord1[1] - coord2[1]).abs

    if length_a > 0 && length_b > 0
      false

    else
      length_a > 0 ? (length_a + 1) : (length_b + 1)
    end
  end
end