MajorType.all().each do |type|
  type.major_ids.each do |major_id|
    major = Major.find(major_id)
    unless major.blank?
      major.major_type_id = type.id
      major.save!
    end
  end
end
Job.where(major_types: nil).each do |job|
  majors = job.majors
  types = job.majors.map{|major| Major.find_by(code: major)}.compact.map{|major| major.major_type_id}.compact
  job[:major_types] = types
  job.save!
end