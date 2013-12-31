require_relative 'setup'

class Player
  attr_reader :fleet, :attack_grid, :name

  def initialize(fleet_builder, shot, name)
    @fleet = Fleet_Factory.new(fleet_builder).fleet
    @shot = shot
    @attack_grid = Grid.new
    @name = name
    @sunk = []
  end

  def turn
    shots = @shot.new(self).shots
    results = volley(shots)
    view_volley_results(results)
  end

  def set_enemy(enemy)
    @enemy = enemy.fleet
  end

  def volley(coords)
    results = coords.collect { |coord| shoot(coord)}
    results.each { |result| mark_result(result) }
    results
  end

  def shoot(coord)
    @enemy.shot_result(coord)
  end

  def mark_result(result)
    @attack_grid.mark_coord(result[:coord], result[:result]) 
    @sunk.push([result[:sunk], result[:coord]]) if result[:sunk]
  end

  def view_volley_results(results)
    hit_miss = {"H" => "hit", "m" => "miss"}

    puts "Shots by #{name}: "
    results.each do |result|
      puts from_coord(result[:coord]) + ":  " + hit_miss[result[:result]]
      puts "Sunk " + result[:sunk] if result[:sunk]
    end

    puts "---------------------"
    puts " "
  end

  def won?
    @sunk.length == @fleet.length
  end

  def shots_count
    shots = @fleet.length - @fleet.sunk
    shots < shots_left ? shots : shots_left
  end

  def already_shot(volley)
    volley.reject { |shot| @attack_grid.empty?(shot)}
  end

  private
  def shots_left
    @attack_grid.empty_spots
  end
end