import Notifier
filename = ARGV[0]
File.readlines(filename).each do |line|
  line = line.chomp
  cols = line.split("\t")
  user = User.find(cols[1])
  invitation = EmailInvitation.find_by(email:user[:email])
  if invitation.nil?
    puts "nil user" + user[:email]
    next
  end
  invite_token = invitation[:_id]

  # sending email to user
  Notifier.email_inactive_user(user, invite_token, "").deliver
  puts user[:email]

end