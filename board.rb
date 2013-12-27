require_relative 'coord'

module GridView
	attr_reader :grid
	def make_grid
		@grid = []
		10.times {@grid.push(Array.new(10, ' '))}
	end

	def view_grid
		letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
		print "     1    2    3    4    5    6    7    8    9    10\n"
		
		(0..9).each do |num| 
			print_line(letters[num], num)
			print "     " + "-" * 46 + "\n"
		end
	end

	def print_line(letter, line_num)
		print "#{letter}    "
		@grid[line_num].each {|point| print "#{point} |  "}
		print "\n"
	end

	def shots_left
		@grid.flatten.count {|point| point == ' '}
	end
end

module VolleyResultsViewer
	include CoordTranslator
	def view_volley_results(results, player)
		hit_miss = {"H" => "hit", "M" => "miss"}

		puts "Shots by #{player.name}: "
		results.each do |result|
			puts from_coord(result[:coord]) + ":  " + hit_miss[result[:result]]
			puts "Sunk " + result[:sunk] if result[:sunk]
		end

		puts "---------------------"
		puts " "
	end
end