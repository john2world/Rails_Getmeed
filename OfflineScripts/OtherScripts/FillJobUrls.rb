Job.all().each{|job|
  if(job[:source] == "JobVite")
    job[:job_url] = "http://hire.jobvite.com/CompanyJobs/Careers.aspx?page=Job+Description&j="+job[:external_id]
    job.save()
  elsif(job[:source] == "AngelList")
    job[:job_url] = "http://angel.co/" + job[:company_id]
    job.save()
  elsif(job[:source] == "VentureLoop")
    job[:job_url] = "http://ventureloop.com/ventureloop/jobdetail.php?jobid="+job[:external_id]
    job.save()
  end
}