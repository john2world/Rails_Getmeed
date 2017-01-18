json.job do
  json.extract! @job, :_id, :title, :email, :location, :description, :live, :compensation, :type, :email, :emails
  json.majors @job.majors
  json.skills @job.skills
  json.schools @job.schools
  json.question @job.question
end
