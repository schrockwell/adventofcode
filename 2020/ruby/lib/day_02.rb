#! /usr/bin/env ruby
require_relative '../common.rb'

lines, answers = read_inputs(2)

# e.g. "3-6 s: ssdsssss"
regex = /^(\d+)-(\d+) (.): (.+)$/

valid_count = 0

lines.each do |line|
  _, min, max, char, password = regex.match(line).to_a
  char_range = min.to_i..max.to_i
  char_count = password.chars.count { |c| c == char }

  valid_count += 1 if char_range.include?(char_count)
end

puts "#{valid_count} valid passwords"

raise unless valid_count.to_s == answers[0]

valid_count = 0

lines.each do |line|
  _, pos1, pos2, char, password = regex.match(line).to_a

  pos1, pos2 = pos1.to_i, pos2.to_i

  pos1_valid = password[pos1 - 1] == char
  pos2_valid = password[pos2 - 1] == char
  
  valid_count += 1 if pos1_valid ^ pos2_valid
end

puts "#{valid_count} valid passwords"

raise unless valid_count.to_s == answers[1]