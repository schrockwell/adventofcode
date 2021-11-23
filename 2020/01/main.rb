#! /usr/bin/env ruby
load '../common.rb'

numbers = read_input.map(&:to_i).sort

low = nil
high = nil

low = numbers.find do |l|
    high = numbers.find do |h|
        l + h == 2020
    end
end

puts "#{low} + #{high} = #{low + high}"
puts "#{low} * #{high} = #{low * high}"