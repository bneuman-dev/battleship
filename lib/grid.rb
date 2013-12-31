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
    letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    print "       A    B    C    D    E    F    G    H    I    J\n"
    
    (1..9).each do |line_num|
      print "#{line_num}      "
      print_line(line_num)
      print "     " + "-" * 49 + "\n"
    end

    print "10     "
    print_line(10)
    print "     " + "-" * 49 + "\n"
  end

  def print_line(line_num)
    @grid.each {|column| print "#{column[line_num - 1]} |  "}
    print "\n"
  end
end