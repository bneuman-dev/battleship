		elsif @ships_cfg.any? { |ship_cfg| (input.downcase.include? ship_cfg[:name].downcase) && ship_cfg[:quantity] > 0}
				add_ship(input)

			elsif input =~ /\d\s[a-jA-J]\d{1,2}\s[a-jA-J]\d{1,2}/
				edit_ship(input)