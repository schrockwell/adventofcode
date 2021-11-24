def read_inputs(day)
    day_string = '%02d' % day
    input = File.read(File.join(__dir__, '..', 'days', day_string, 'input.txt')).split("\n").select { |s| s != '' }
    answers = File.read(File.join(__dir__, '..', 'days', day_string, 'answers.txt')).split("\n").select { |s| s != '' }

    return input, answers
end 