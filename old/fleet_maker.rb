require_relative 'ship_maker'

module Fleet_Maker
  attr_reader :fleet

  def initialize_fleet
    @fleet = []
  end

  def coords
    @fleet.collect {|ship| ship.coords}.flatten(1)
  end


end