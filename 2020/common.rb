def read_inputs(dir)
    input = File.read(File.join(dir, 'input.txt')).split("\n").select { |s| s != '' }
    answer = File.read(File.join(dir, 'answer.txt')).strip

    return input, answer
end