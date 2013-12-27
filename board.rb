module GridView

	class Grid

		attr_accessor :board
		def initialize
			@board = []
			10.times {@board.push(Array.new(10, ' '))}
		end

		def view_board
			letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
			print "     1    2    3    4    5    6    7    8    9    10\n"
			
			(0..9).each do |num| 
				print_line(letters[num], num)
				print "     " + "-" * 46 + "\n"
			end
		end

		def print_line(letter, line_num)
			print "#{letter}    "
			@board[line_num].each {|point| print "#{point} |  "}
			print "\n"
		end
	end

end