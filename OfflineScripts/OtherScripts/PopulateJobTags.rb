# Script to populate the Profile tags for profiles. This is a one of script to populate the tags.
# Author: VMK@

require 'thread/pool'

ThreadPoolLimit = 5
include JobsHelper

def generate_save_tags(job)
  begin
    if job[:tags] != nil
      return
    end
    tags = get_job_tags(job)
    job[:tags] = tags
    job.save()
  rescue Exception => ex
    puts "Exception for job (#{job[:_id]}): #{ex}"
  end
end

pool = Thread.pool(ThreadPoolLimit);
start_time = Time.now
#Job.desc(:create_dttm).each do |job|
Job.where(:tags => nil).shuffle().each do |job|
  pool.process{generate_save_tags(job)}
end
pool.shutdown
end_time = Time.now
puts "Time taken: #{end_time - start_time}"
