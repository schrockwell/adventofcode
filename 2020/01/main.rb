#! /usr/bin/env ruby
require_relative '../common.rb'

input, answer = read_inputs(__dir__)
input = input.map(&:to_i)
answer = answer.to_i

low = nil
high = nil

low = input.find do |l|
    high = input.find do |h|
        l + h == 2020
    end
end

puts "#{low} + #{high} = #{low + high}"
puts "#{low} * #{high} = #{low * high}"

raise unless low + high == answer
