require_relative 'setup'

class Grid
  attr_reader :grid

  def initialize
    @grid = []
    10.times {@grid.push(Array.new(10, ' '))}
  end

  def mark_coords(coords, marking)
    coords.each do |coord|
      mark_coord(coord, marking)
    end
  end

  def mark_coord(coord, marking)
    @grid[coord[0]][coord[1]] = marking
  end

  def get_coord(coord)
    @grid[coord[0]][coord[1]]
  end

  def empty?(coord)
    get_coord(coord) == ' '
  end

  def empty_spots
    @grid.flatten.count {|point| point == ' '}
  end

  def view_grid
    print "       1    2    3    4    5    6    7    8    9    10\n"
    print "     " + "-" * 49 + "\n"
    (1..10).each do |line_num|
      
      print_line(line_num)
      print "     " + "-" * 49 + "\n"
    end
  end

  def print_line(line_num)
    letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    print "#{letters[line_num - 1]}      "
    @grid[line_num - 1].each {|point| print "#{point} |  "}
    print "\n"
  end
end