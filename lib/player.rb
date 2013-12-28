require_relative 'boards'
require_relative 'volley_results'

class Combatant
	attr_reader :fleet, :attack_grid, :name

	def initialize(fleet)
		@fleet = fleet
		@attack_grid = Attack_Grid.new
		@name = name
	end

	def set_enemy(enemy)
		@enemy = enemy.fleet
	end

	def shots_count
		@fleet.number_of_ships - @fleet.sunk
	end

	def shots_left
		@attack_grid.shots_left
	end

	def volley(coords)
		results = coords.collect { |coord| shoot(coord)}
		results.each { |result| mark_result(result) }
		results
	end

	def shoot(coord)
		@enemy.get_shot(coord)
	end

	def mark_result(result)
		@attack_grid.mark_result(result)
	end

	def won?
		@attack_grid.sunk.length == @fleet.number_of_ships
	end

	def already_shot(volley)
		volley.select { |shot| @attack_grid.already_shot(shot)}
	end
end

class Player
	include VolleyResultsViewer

	attr_reader :name, :combatant
	def initialize(combatant, shot, name)
		@combatant = combatant
		@shot = shot
		@name = name
	end

	def turn
		shots = @shot.new(@combatant, @name).shots
		results = @combatant.volley(shots)
		view_volley_results(results, self)
	end

	def won?
		@combatant.won?
	end

	def set_enemy(enemy)
		enemy.make_enemy(@combatant)
	end

	def make_enemy(enemy_comb)
		@combatant.set_enemy(enemy_comb)
	end
end