#! /usr/bin/env ruby
require_relative '../common.rb'

numbers, answers = read_inputs(1)
numbers = numbers.map(&:to_i)
answers = answers.map(&:to_i)

low = nil
high = nil

low = numbers.find do |l|
    high = numbers.find do |h|
        l + h == 2020
    end
end

puts "#{low} + #{high} = #{low + high}"
puts "#{low} * #{high} = #{low * high}"

raise unless low + high == 2020
raise unless low * high == answers[0]

mid = nil

low = numbers.find do |l|
    mid = numbers.find do |m|
        high = numbers.find do |h|
            l + m + h == 2020
        end
    end
end

puts "#{low} + #{mid} + #{high} = #{low + mid + high}"
puts "#{low} * #{mid} * #{high} = #{low * mid * high}"

raise unless low + mid + high == 2020
raise unless low * mid * high == answers[1]
