require_relative 'setup'

def check
	games = []
	50.times do
		games.push(Game_Setup.new("Ben", "Neb"))
	end

	games.collect { |game|
		[game.game.player1.combatant.fleet.coords.length, game.game.player2.combatant.fleet.coords.length]
	}
end