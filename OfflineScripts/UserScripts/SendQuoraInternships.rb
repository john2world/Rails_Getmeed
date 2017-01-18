# finding 50 students from UFL, UW and Gatech
gatech_users = User.where(:email => /gatech.edu/).where(:active => false).take(50);
uw_users = User.where(:email => /uw.edu/).where(:active => false).take(50);
ufl_users = User.where(:email => /ufl.edu/).where(:active => false).take(50);

job_id = "53d7f08d05af2cb5bf000004"

# sending emails to Gatech students
gatech_users.each do |user|
  EmailJobInvitationWorker.perform_async(user[:email], job_id)
end

puts "Send emails to Gatech users"

# sending emails to uw_users students
uw_users.each do |user|
  EmailJobInvitationWorker.perform_async(user[:email], job_id)
end

puts "Send emails to UW users"

# sending emails to ufl_users students
ufl_users.each do |user|
  EmailJobInvitationWorker.perform_async(user[:email], job_id)
end

puts "Send emails to Ufl users"