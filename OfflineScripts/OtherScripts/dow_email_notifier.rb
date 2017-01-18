import Random
random = Random.new
inactive_users = User.where(active: false).to_a

inactive_users.each do |user|
  dow = random.rand(1..7)
  puts "#{dow}\t#{user[:_id]}"
end