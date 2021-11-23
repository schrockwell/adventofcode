def read_input    
    File.read('input.txt').split("\n").select { |s| s != '' }
end