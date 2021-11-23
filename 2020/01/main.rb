#! /usr/bin/env ruby
require_relative '../common.rb'

numbers = read_input(File.dirname(__FILE__)).map(&:to_i)

low = nil
high = nil

low = numbers.find do |l|
    high = numbers.find do |h|
        l + h == 2020
    end
end

puts "#{low} + #{high} = #{low + high}"
puts "#{low} * #{high} = #{low * high}"

raise 'Wrong result' unless low + high == 2020

raise 'testing'