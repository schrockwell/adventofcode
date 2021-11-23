def read_input(dir)  
    File.read(File.join(dir, 'input.txt')).split("\n").select { |s| s != '' }
end