require_relative 'setup'

def to_coord(letter_form)
  letters = {a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9}
  coord_x = letters[letter_form[0].to_sym]
  coord_y = letter_form[1..-1].to_i - 1
  [coord_x, coord_y]
end

def from_coord(coord)
  numbers = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I','J']
  x_letter = numbers[coord[0]]
  y_number = (coord[1] + 1).to_s
  x_letter + y_number
end