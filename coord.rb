module CoordTranslator
	LETTERS = {a: 0, b: 1, c: 2, d: 3, e: 4, f: 5, g: 6, h: 7, i: 8, j: 9}
	NUMBERS = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I','J']

	def to_coord(letter_form)
		coord_x = translate_letter(letter_form[0])
		coord_y = letter_form[1..-1].to_i - 1
		[coord_x, coord_y]
	end

	def translate_letter(letter)
		LETTERS[letter.downcase.to_sym]
	end

	def from_coord(coord)
		letter = NUMBERS[coord[0]]
		number = (coord[1] + 1).to_s
		letter + number
	end
end