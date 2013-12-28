describe Board do
	it { should respond_to(:board) }
	its('board.length') { should == 10 }

	it "has all rows of 10" do
	  subject.board.all? { |row|
	  	row.length == 10
	  	}.should be_true
	end

	it "should check ship placement" do
		subject.check_ship_placement('A2', 'A6', 5).should be_true
		subject.check_ship_placement('A2', 'C2', 3).should be_true
		subject.check_ship_placement('A2', 'A2', 1).should be_true
		subject.check_ship_placement('A2', 'C4', 4).should be_false
		subject.check_ship_placement('A2', 'C2', 2).should be_false
		subject.check_ship_placement('E3', 'E7', 4).should be_false
	end

end

describe "Ship" do

	it "should be valid distance is correct" do
		good_ship = Ship.new('A2', 'A6', 5)
		good_ship.should be_valid
	end

	it "should be valid ship length 1 correct coordinates" do
		good_ship = Ship.new('A2', 'A2', 1)
		good_ship.should be_valid
	end

	it "should be valid distance is correct X axis" do
		good_ship = Ship.new('A2', 'C2', 3)
		good_ship.should be_valid
	end

	it "should be invalid bad coordinates" do
		bad_ship = Ship.new('A2', 'C4', 4)
		bad_ship.should_not be_valid
	end

	it "should be invalid bad distance" do
		bad_ship = Ship.new('A2', 'D2', 5)
		bad_ship.should_not be_valid
	end
end

describe "Carrier" do
	subject {Carrier.new('A2', 'A6')}
	its(:length) {should == 5}
end

describe "Battleship" do
	subject {Battleship.new('A2', 'A5')}
	its(:length) {should == 4}
end

describe "Cruiser" do
	subject {Cruiser.new('A2', 'A4')}
	its(:length) {should == 3}
end

describe "Destroyer" do
	subject {Destroyer.new('A2', 'A3') }
	its(:length) {should == 2}
end

describe "Submarine" do
	subject {Submarine.new('A2', 'A2')}
	its(:length) {should == 1}
end