require './OfflineScripts/JobScrappers/JobHelper.rb'
include JobHelper

Job.all().each{|job|
  job[:type] = get_job_type(job[:title])
  job.save()
}