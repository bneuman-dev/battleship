require_relative 'coord_translator'

class Human_Shot
	attr_reader :shots
	include CoordTranslator

	def initialize(combatant, name)
		@shots_count = combatant.shots_count
		@combatant = combatant
		@name = name
		@combatant.attack_grid.view_grid
		puts "#{@name}, you have #{@shots_count} shots. Shoot"
		@shots = make_shots
	end

	def make_shots
		shots = gets.chomp

		shots = process_input(shots)

		if shots.length < @shots_count && shots.length < @combatant.shots_left
			puts "Too few shots, you have #{@shots_count} shots. Shoot again."
	

		elsif shots.length > @shots_count
			puts "Too many shots, you only have #{@shots_count} shots. Shoot again."

		elsif shots.uniq != shots
			puts "You can't shoot the same coordinate twice in the same volley. Shoot again."

		elsif @combatant.already_shot(shots) != []
			print "You already shot "
			@combatant.already_shot(shots).each do |shot|
				print "#{from_coord(shot)} "
			end
			print "\n"

		else
			return shots
		end

		make_shots
	end

	def process_input(input)
		coords = input.scan(/[A-J|a-j]10|[A-J|a-j][1-9]/)
		coords.collect do |coord|
			to_coord(coord)
		end
	end
end

class Computer_Shot
	attr_reader :shots
	def initialize(combatant, name)
		@shots_count = combatant.shots_count
		@combatant = combatant
		@name = name
		@shots = make_shots
	end

	def make_shots
		shots = []

		@shots_count.times do
			shot = make_shot
			while shots.include? shot
				shot = make_shot
			end
			shots.push(shot)
		end

		if @combatant.already_shot(shots) != []
			make_shots

		else
			shots
		end
	end

	def make_shot
		[rand(9), rand(9)]
	end
end