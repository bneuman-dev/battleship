require 'spec_helper'
require_relative '../battleship'


describe "Coord translator" do
	class Dummy
		include CoordTranslator
	end

	before do
		@dummy = Dummy.new
	end

	it "should translate coord to letter" do
		@dummy.from_coord([0,0]).should == "A1"
	end

	it "coord to letter" do
		@dummy.from_coord([4,4]).should == "E5"
	end

	it "coord to letter" do
		@dummy.from_coord([2,8]).should == "C9"
	end

	it "coord to letter" do
		@dummy.from_coord([9,9]).should == "J10"
	end

	it "should translate letter to coord" do
		@dummy.to_coord("A1").should == [0,0]
	end

	it "letter to coord" do
		@dummy.to_coord("C3").should == [2,2]
	end

	it "letter to coord" do 
		@dummy.to_coord("J10").should == [9,9]
	end

	it "letter to coord" do
		@dummy.to_coord("F7").should == [5,6]
	end
	
end

describe "Ship on the y axis" do
	subject { Ship.new(name: "Carrier", coord1: [0,0], coord2: [0,4], length: 5) }

	it { should be_valid }
	its(:name) { should == "Carrier" }
	its(:coords) { should == [[0,0], [0,1], [0,2], [0,3], [0,4]] }
	its(:length) { should == 5 }
end

describe "Ship on the x axis" do
	subject { Ship.new(name: "Battleship", coord1: [5,2], coord2: [2,2], length: 4 )}

	it { should be_valid }
	its(:name) { should == "Battleship" }
	its(:coords) { should == [[2,2], [3,2], [4,2], [5,2]] }
	its(:length) { should == 4 }
end

describe "Ships should not be valid if coords not horizontal or vertical" do
	subject { Ship.new(name: "Cruiser", coord1: [4,2], coord2: [3,4], length: 3) }

	it { should_not be_valid }
	its(:coords) { should be_nil }
	its(:length) { should be_nil }
end

describe "Ship should not be valid if distance between coords != length" do
	subject { Ship.new(name: "Cruiser", coord1: [4,2], coord2: [4,5], length: 3) }

	it { should_not be_valid }
	its(:coords) { should be_nil }
	its(:length) { should be_nil }
end

describe "Ship should not be valid if coord has value < 0" do
	subject { Ship.new(name: "Cruiser", coord1: [-2,2], coord2: [0,2], length: 3) }
	it { should_not be_valid}
end

describe "Ship should not be valid if coord has value > 9" do
	subject { Ship.new(name: "Cruiser", coord1: [4,9], coord2: [4,11], length: 3) }
	it { should_not be_valid}
end

describe "Ship should not be valid if coord is non-integer" do
	subject { Ship.new(name: "Cruiser", coord1: [0,2.2], coord2: [0,5.2], length: 4) }
	it { should_not be_valid}
end

describe "Ships" do
	
	ship1 = Ship.new(name: "Carrier", coord1: [0,0], coord2: [0,4], length: 5)
	subject { Ships.new([ship1]) }

	its(:ships) { should == [ship1] }
	its(:coords) { should == ship1.coords }
	
	ship2 = Ship.new(name: "Destroyer", coord1: [0,4], coord2: [1,4], length: 2)

	it "shouldn't let you add two ships on same coordinate" do
		subject.add_ship(ship2).should be_false
	end

	it "shiplist should not change when you add two ships on same coordinate" do
		subject.add_ship(ship2)
		subject.ships.should_not include(ship2)
	end

	it "coordinate list should not change when you add two ships on same coordinate" do
		subject.add_ship(ship2)
		subject.coords.should_not include([1,4])
	end
end

describe "Board" do
	ship1 = Ship.new(name: "Carrier", coord1: [0,0], coord2: [0,4], length: 5)
	ship2 = Ship.new(name: "Battleship", coord1: [5,2], coord2: [2,2], length: 4 )
	ship3 = Ship.new(name: "Destroyer", coord1: [7,3], coord2: [7,4], length: 2)
	ships = Ships.new(ships=[ship1, ship2, ship3])
	board = Board.new(ships)

	it "should return true on hit" do
		result = board.get_shot([3,2])
		result[:result].should == "H"
		result[:coord].should == [3,2]
		result[:sunk].should == false
	end

	it "should return true on hit" do
		result = board.get_shot([0,3])
		result[:result].should == 'H'
		result[:coord].should == [0,3]
		result[:sunk].should == false
	end

	it "should return false on miss" do
		result = board.get_shot([0,6])
		result[:result].should ==  "M" 
		result[:coord].should == [0,6]
		result[:sunk].should == nil
	end

	it 'should return false on miss' do
		result = board.get_shot([8,2])
		result[:result].should == "M"
		result[:coord].should == [8,2]
		result[:sunk].should == nil
	end

	it 'should return sunk on sunk' do
		board.get_shot([7,3])
		result = board.get_shot([7,4])
		result[:result].should == "H"
		result[:coord].should == [7,4]
		result[:sunk].should == "Destroyer"
	end
end

describe "Offense Board" do
	ship1 = Ship.new(name: "Carrier", coord1: [0,0], coord2: [0,4], length: 5)
	ship2 = Ship.new(name: "Battleship", coord1: [5,2], coord2: [2,2], length: 4 )
	ship3 = Ship.new(name: "Destroyer", coord1: [7,3], coord2: [7,4], length: 2)
	ships = Ships.new(ships=[ship1, ship2, ship3])
	board = Board.new(ships)
	o_board = Offense_Board.new
	o_board.enemy_board = board

	context "on double shot" do
		o_board.shoot([3,2])
		it "should be false" do
			o_board.shoot([3,2]).should be_false
		end
	end

	context "on miss" do
		o_board.shoot([0,5])
		it "should log miss" do
			o_board.get_coord([0,5]).should == "M"
		end
	end

	context "on hit" do
		o_board.shoot([0,2])
		it "should log hit" do
			o_board.get_coord([0,2]).should == "H"
		end
	end

	context "on start" do
		o_board2 = Offense_Board.new
		o_board2.enemy_board = Board.new(ships)
		it "should start off null" do
			o_board2.get_coord([rand(10), rand(10)]).should == "N"
		end
	end

	context "should log sink" do
		o_board.shoot([7,3])
		o_board.shoot([7,4])
		it "first coord should" do
			o_board.sunk[-1].should == ["Destroyer", [7,4]]
		end
	end
end

