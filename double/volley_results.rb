require_relative 'coord_translator'

module VolleyResultsViewer
	include CoordTranslator
	def view_volley_results(results, player)
		hit_miss = {"H" => "hit", "m" => "miss"}

		puts "Shots by #{player.name}: "
		results.each do |result|
			puts from_coord(result[:coord]) + ":  " + hit_miss[result[:result]]
			puts "Sunk " + result[:sunk] if result[:sunk]
		end

		puts "---------------------"
		puts " "
	end
end