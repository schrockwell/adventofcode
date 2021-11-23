def read_inputs(day)
    day_string = '%02d' % day
    input = File.read(File.join(__dir__, '..', 'days', day_string, 'input.txt')).split("\n").select { |s| s != '' }
    answer = File.read(File.join(__dir__, '..', 'days', day_string, 'answer.txt')).strip

    return input, answer
end 