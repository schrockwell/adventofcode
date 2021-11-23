#! /usr/bin/env ruby
require_relative '../common.rb'

numbers, answer = read_inputs(__dir__)
numbers = numbers.map(&:to_i)
answer = answer.to_i

low = nil
high = nil

low = numbers.find do |l|
    high = numbers.find do |h|
        l + h == 2020
    end
end

puts "#{low} + #{high} = #{low + high}"
puts "#{low} * #{high} = #{low * high}"

raise unless low + high == answer
