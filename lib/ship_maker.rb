require_relative 'setup'

Ship = Struct.new(:name, :length, :coords)

class Ship_Maker
  attr_reader :ship

  def initialize(ship_cfg)
    @ship_cfg = ship_cfg
    @coord1 = ship_cfg[:coord1]
    @coord2 = ship_cfg[:coord2]
    @length = ship_cfg[:length]
    coords = make_coords
    @ship = Ship.new(@ship_cfg[:name], @ship_cfg[:length], coords)
  end

  def make_coords
    coord_range = get_coords_alignment
    start_index, end_index = get_indices(coord_range)
    check_length(start_index, end_index)
    coord_range[start_index..end_index]
  end

  def get_coords_alignment
    coord1_row = ROWS.find { |row| row.include? @coord1 }
    coord1_column = COLUMNS.find { |column| column.include? @coord1 }

    coord2_in_row = coord1_row.include? @coord2
    coord2_in_column = coord1_column.include? @coord2

    raise InvalidShipException.new("Weird alignment") if !(coord2_in_row) && !(coord2_in_column)

    coord2_in_row ? coord1_row : coord1_column
  end

  def get_indices(coord_range)
    start_index = coord_range.index(@coord1)
    end_index = coord_range.index(@coord2)
    start_index < end_index ? [start_index, end_index] : [end_index, start_index]
  end

  private

  def check_length(start_index, end_index)
    length = (end_index - start_index).abs + 1
    raise InvalidShipException.new("Bad length") if length != @length
  end
end