require_relative 'setup'
require 'debugger'

Ship = Struct.new(:name, :length, :coords)

class ShipMaker
  attr_reader :ship

  def initialize(ship_cfg)
    @ship_cfg = ship_cfg
   # debugger
    @coord1, @coord2 = [ship_cfg[:coord1], ship_cfg[:coord2]].sort
    @length = ship_cfg[:length]
    check_alignment
    check_length
    coords = fill_in_coords
    @ship = Ship.new(@ship_cfg[:name], @ship_cfg[:length], coords)
  end

  def fill_in_coords
    in_same_row? ? fill_in_row : fill_in_column
  end

  def fill_in_row
    (@coord1..@coord2).to_a
  end

  def fill_in_column
    (@coord1 / 10..@coord2 / 10).collect do |coord|
      (coord * 10) + (@coord1 % 10)
    end
  end

  def check_alignment
    raise InvalidShipException.new("Bad alignment") if !in_same_row? && !in_same_column?
  end

  def in_same_row?
    @coord1 / 10 == @coord2 / 10
  end

  def in_same_column?
    @coord1 % 10 == @coord2 % 10
  end

  def check_length
    raise InvalidShipException.new("Bad length") if row_length != @length && column_length != length
  end

  def row_length
    (@coord2 - @coord1) + 1
  end

  def column_length
    (@coord2 / 10 - @coord1 / 10) + 1
  end
end