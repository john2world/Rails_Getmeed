include CommonHelper

def get_duplicate_job(leftJob, rightJob)
  left_applications = JobApplicant.find_by(job_id: leftJob[:_id])
  right_applications = JobApplicant.find_by(job_id: rightJob[:_id])
  if (not left_applications.blank?) &&
     (not right_applications.blank?) &&
    left_applications[:handles].count < right_applications[:handles].count
    # since left job has less no of applies it is marked as duplicate
    return -1
  else
    return 1
  end
end
def compare_jobs(leftJob, rightJob)
  if (not leftJob.blank?) &&
     (not rightJob.blank?) &&
     (not leftJob[:job_url].blank?) &&
     (not rightJob[:job_url].blank?) &&
      leftJob[:job_url] == rightJob[:job_url]
    # these jobs are duplicate getting which one should be the master
    return get_duplicate_job(leftJob, rightJob)
  else
    return 0
  end
end
def move_job_meta(original_job, parent_job)
  # moving job applications
  parent_job_applications = JobApplicant.find_by(job_id: parent_job[:_id])
  original_job_applications = JobApplicant.find_by(job_id: original_job[:_id])
  if (not original_job_applications.blank?)
    if(parent_job_applications.blank?)
      original_job_applications[:_id] = parent_job[:_id]
      original_job_applications[:job_id] = parent_job[:_id]
      original_job_applications.save()
    else
      parent_job_applications[:handles].concat(original_job_applications)
      parent_job_applications.save()
    end
  end


  # moving job applicants
  original_job_applications = JobApplicant.find_by(job_id: original_job[:_id])
  # for each applicant move it to new jobid
  if (not original_job_applications.blank?)
    original_job_applicants.each do |applicant|
      applicant[:job_id] = parent_job[:_id]
      applicant[:_id] = applicant[:_id].sub! original_job[:_id], parent_job[:_id]
    end
  end

  # moving job views
  original_job_views = JobView.where(:job_id => original_job[:_id])
  # for each such job move it to new jobid
  if(not original_job_views.blank?)
    original_job_views.each do |view|
      view[:_id] = view[:_id].sub! original_job[:_id], parent_job[:_id]
      view[:job_id] = parent_job[:_id]
      view.save()
    end
  end

  # moving user Applied Jobs
  original_job_user_jobs = UserAppliedJobs.where(job_ids: original_job[:_id])
  # for each user applied jobs remove the old job id and add new job id
  if (not original_job_user_jobs.blank?)
    original_job_user_jobs.each do |user_job|
      # removing old id
      user_job.job_ids.remove(original_job[:_id])
      # adding new id if not already present
      if not user_job.job_ids.include? parent_job[:_id]
        user_job.job_ids.push(parent_job[:_id])
      end
      user_job.save()
    end
  end

  # moving user job app stats
  original_job_app_stats = UserJobAppStats.where(job_id: original_job[:_id])
  # for each app stats update the original job id with new job id
  if (not original_job_app_stats.blank?)
    original_job_app_stats.each do |app_stats|
      app_stats[:job_id] = parent_job[:_id]
      app_stats.save()
    end
  end

  # user jobs use hashed id
  original_job_id_hash = encode_id(original_job[:_id])
  parent_job_id_hash = encode_id(parent_job[:_id])
  original_user_jobs = UserJobs.where(job_ids: original_job_id_hash)
  # for each original job id hash replace with new job id hash
  if (not original_user_jobs.blank?)
    original_user_jobs.each do |user_job|
      user_job.job_ids.remove(original_job_id_hash)
      if not user_job.job_ids.include? parent_job_id_hash
        user_job.job_ids.push(parent_job_id_hash)
      end
    end
  end

end
Company.all().each{|company|
  # getting jobs for the company
  jobs_to_delete = []
  jobs = Job.where(company_id:company[:_id])
  jobs.each do |outer_job|
    if jobs_to_delete.include? outer_job
      next
    end
    jobs.each do |inner_job|
      if outer_job[:_id] == inner_job[:_id]
        next
      end
      if jobs_to_delete.include? inner_job
        next
      end

      result = compare_jobs(outer_job, inner_job)

      # if result = -1, delete left (outer_job) else delete right (inner_job)
      if result == -1
        move_job_meta(outer_job, inner_job)
        # delete the left (outer document).
        # since no more comparisons will be required, breaking out of the loop
        outer_job.delete()
        jobs_to_delete.push(outer_job)
        break
      elsif result == 1
        move_job_meta(inner_job, outer_job)
        # delete the right (inner job)
        inner_job.delete()
        jobs_to_delete.push(inner_job)
      else
        # no duplicate and hence nothing to do
      end
    end
  end

}