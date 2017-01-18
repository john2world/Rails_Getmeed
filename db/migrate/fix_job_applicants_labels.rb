jobs = Job.all();

def fixApplicants(applications, applicants)
  applications[0][:handles].each do |handle|
    if (!applicants.where(:handle => handle).exists?)
      JobApplicant.create(
          _id: handle+"_"+applications[0][:_id],
          job_id: applications[0][:_id],
          handle: handle,
          notes: nil,
          create_dttm: Time.now
      )
    end
  end

  applicants.each do |applicant|
    if (!applications[0][:handles].include?(applicant[:handle]))
      applications[0].push(:handles, applicant[:handle])
    end
  end
  applications[0].save()
end

def fixLabels(applicants, labels)
  applicants.each do |applicant|
    stat = UserJobAppStats.find(applicant[:_id]);
    if (stat.blank?)
      # missing label so create one
      UserJobAppStats.create(
          _id: applicant[:_id],
          job_id: applicant[:job_id],
          handle: applicant[:handle],
          status: 'NEW'
      )
    else
      if stat[:job_id].blank?
        stat.update_attributes(job_id: applicant[:job_id]);
      end
      if stat[:handle].blank?
        stat.update_attributes(handle: applicant[:handle]);
      end
      if stat[:status].blank?
        stat.update_attributes(status: 'NEW');
      end
    end
  end
  # fix other way around
  labels.each do |label|
    applicant = JobApplicant.find(:_id=>label[:_id]);
    if (applicant.blank?)
      JobApplicant.create(
          _id: label[:_id],
          job_id: label[:job_id],
          handle: label[:handle]
      )
    else
      if applicant[:job_id].blank?
        applicant.update_attributes(job_id: label[:job_id]);
      end
      if applicant[:handle].blank?
        applicant.update_attributes(handle: label[:handle]);
      end
    end
  end
end

jobs.each do |job|
  # JobApplications is retired
  #applications = JobApplications.where(job_id: job[:_id]);
  applications = nil;
  applicants = JobApplicant.where(job_id: job[:_id]);
  labels = UserJobAppStats.where(job_id: job[:_id]);

  #if applications.exists? && applications[0][:handles].count() != applicants.count()
  #  puts "Fixing applicants for job id: "+job[:_id];
  #  fixApplicants(applications,applicants)
  #end

  if applicants.exists? && applicants.count() != labels.count()
    puts "Fixing labels for job id: "+job[:_id];
    fixLabels(applicants, labels);
  end
end