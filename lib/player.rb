require_relative 'setup'

class Player
  attr_reader :fleet, :attack_grid, :name

  def initialize(fleet_builder, shot_chooser, name)
    @fleet = Fleet_Factory.new(fleet_builder).fleet
    @shot_chooser = shot_chooser
    @attack_grid = Grid.new
    @name = name
    @sunk = []
  end

  def set_enemy(enemy)
    @enemy = enemy.fleet
  end

  def turn
    Turn.new(self)
  end

  def make_shots
    @shot_chooser.new(self).shots
  end

  def shoot(coord)
    @enemy.shot_result(coord)
  end

  def mark_result(result)
    @attack_grid.mark_coord(result[:coord], result[:result]) 
    @sunk.push([result[:sunk], result[:coord]]) if result[:sunk]
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

class Turn
  def initialize(player)
    @player = player
    turn
  end

  def turn
    make_shots
    volley
    mark_results
    view_results
  end

  def make_shots
    @shots = @player.make_shots
  end

  def volley
    @results = @shots.collect { |shot| shoot(shot)}
  end

  def shoot(shot)
    @player.shoot(shot)
  end

  def mark_results
    @results.each { |result| @player.mark_result(result) }
  end

  def view_results
    hit_miss = {"H" => "hit", "m" => "miss"}

    puts "Shots by #{@player.name}: "
    @results.each do |result|
      puts from_coord(result[:coord]) + ":  " + hit_miss[result[:result]]
      puts "Sunk " + result[:sunk] if result[:sunk]
    end

    puts "---------------------"
    puts " "
  end
end
