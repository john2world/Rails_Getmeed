class GenerateJobTagsWorker
  include Sidekiq::Worker
  include JobsHelper
  sidekiq_options retry: true, :queue => :default

  def perform(job_id)
    job = Job.find(job_id)
    tags = get_job_tags(job)
    unless tags.blank?
      job[:tags] = tags
      job.save()
    end
  end
end