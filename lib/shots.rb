require_relative 'setup'

class HumanShotChooser
  attr_reader :shots

  def initialize(player)
    @shots_count = player.shots_count
    @player = player
    @name = player.name
    @player.attack_grid.view_grid
    puts "#{@name}, you have #{@shots_count} shots. Shoot"
    @shots = make_shots
  end

  def make_shots

    not_shot = true

    while not_shot
      shots = gets.chomp

      shots = process_input(shots)

      if shots.length < @shots_count
        puts "Too few shots, you have #{@shots_count} shots. Shoot again."
    

      elsif shots.length > @shots_count
        puts "Too many shots, you only have #{@shots_count} shots. Shoot again."

      elsif shots.uniq != shots
        puts "You can't shoot the same coordinate twice in the same volley. Shoot again."

      elsif @player.already_shot(shots) != []
        print "You already shot "
        @player.already_shot(shots).each do |shot|
          print "#{from_coord(shot)} "
        end
        print "\n"

      else
        not_shot = false
      end
    end
    
    shots
  end


  def process_input(input)
    coords = input.scan(/[A-J|a-j]10|[A-J|a-j][1-9]/)
    coords.collect do |coord|
      to_coord(coord)
    end
  end
end

class ComputerShotChooser
  attr_reader :shots
  def initialize(player)
    @shots_count = player.shots_count
    @player = player
    @name = player.name
    @shots = make_shots
  end

  def make_shots
    shots = []

    @shots_count.times do
      shot = make_shot
      while shots.include? shot
        shot = make_shot
      end
      shots.push(shot)
    end

    if @player.already_shot(shots) != []
      make_shots

    else
      shots
    end
  end

  def make_shot
    rand(80)
  end
end