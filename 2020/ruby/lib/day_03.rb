#! /usr/bin/env ruby
require_relative '../common.rb'

rows, answers = read_inputs(3)

slope_x = 3
slope_y = 1
width = rows[0].length

x = 0
y = 0
tree_count = 0

loop do
  x = x + slope_x
  y = y + slope_y

  char = rows[y][x % width]
  tree_count += 1 if char == '#'

  break if y >= (rows.length - 1)
end

puts "Encountered #{tree_count} trees"

raise unless tree_count.to_s == answers[0]