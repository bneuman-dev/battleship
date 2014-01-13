require_relative 'setup'

def to_coord(letter_form)
  COORDS.index(letter_form.upcase)
end

def from_coord(coord)
  COORDS[coord]
end