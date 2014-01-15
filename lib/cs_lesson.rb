a = [1,2,3,4]
b = [4,5,6]

c = []
O(a*b)
a.each do |a_val|
  # c << b.include? a_val # little faster in best case
  b.each do |b_val|
    c << a_val if a_val == b_val
  end
end

my_hash = {}
O(a)
a.each do |a_val|
  my_hash[a_val] = true
end

O(b)
b.each do |b_val
  c << b_val if my_hash[b_val]
end

O(a + b)


require 'set'
a = Set.new
s.add(1)


a & b

