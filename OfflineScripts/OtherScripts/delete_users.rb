filename = ARGV[-1]
puts "Deleting users from file: "+filename
File.readlines(filename).each do |line|
  line = line.chomp
  cols = line.split("\t")
  user = User.find(cols[0])
  if user != nil
    puts "deleting email: " + cols[0]
    user.delete
  end
end