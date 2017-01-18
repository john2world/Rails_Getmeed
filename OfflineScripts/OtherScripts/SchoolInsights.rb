DegreeMapping = {
    "Bachelor of Science" => "Bachelor of Science",
    "Master of Science" => "Master of Science",
    "Bachelor's of arts" => "Bachelor of Arts",
    "Bachelor's of Science" => "Bachelor of Science",
    "Bachelor" => "Bachelors",
    "Bachelors of Arts" => "Bachelor of Arts",
    "B.A"  => "Bachelor of Arts",
    "Masters in Science" => "Master of Science",
    "Masters of Science" => "Master of Science",
    "MBA" => "MBA",
    "Bachelor of Arts" => "Bachelor of Arts",
    "MASTERS" => "Master of Science",
    "Master of Computer Science " => "Master of Science",
    "M.S. Biotechnology" => "Master of Science",
    "B.A. Biological Sciences"  => "Bachelor of Arts",
    "Bachelors of Sciences" => "Bachelor of Science",
    "Master Of Science" => "Master of Science",
    "Master of Science " => "Master of Science",
    "PhD" => "PhD",
    "masters of science" => "Master of Science",
    "Masters" => "Master of Science",
    "master of science" => "Master of Science",
    "Bachelor of Music Technology" => "Bachelor of Music Technology",
    "M.S" => "Master of Science",
    "MS" => "Master of Science",
    "MASTER OF COMPUTER SCIENCE" => "Master of Science",
    "Masters Of Science" => "Master of Science",
    "Master of Sciences" => "Master of Science",
    "BS" => "Bachelor of Science",
    "Masters in Computer Science" => "Master of Science",
    "Bachelors" => "Bachelors",
    "Bachelors of Science" => "Bachelor of Science",
    "Computer Engineering" => "Computer Engineering" ,
    "Bachelors of Science " => "Bachelor of Science",
    "Bachelors of Engineering" => "Bachelor of Engineering",
    "Doctor of Philosophy" => "PhD",
    "Master of science" => "Master of Science",
    "BA" => "Bachelor of Arts",
    "B.S." => "Bachelor of Science",
    "Bachelor of Engineering" => "Bachelor of Engineering",
    "Master in Science" => "Master of Science",
    "Master Of Scienece" => "Master of Science",
    "Master's of Science" => "Master of Science",
    "Bachelor or Science" => "Bachelor of Science",
    "Mater of Computer Science" => "Master of Science",
    "Econ" => "Economics",
    "Electrical Engineering and Computer Science" => "Electrical Engineering",
    "Bachelor in Arts " => "Bachelor of Arts",
    "Candidate in Bachelor of Arts " => "Bachelor of Arts",
    "Master of Human-Computer Interaction"  => "Master of Human-Computer Interaction",
    "Master of International Strategic Corporate Communication Management" => "Master of International Strategic Corporate Communication Management",
    "Master of Computer Science" => "Master of Science",
    "Economics" => "Economics",
    "Masters of Science " => "Master of Science",
    "Master" => "Master of Science",
    "Masters of science" => "Master of Science",
    "Master of Engineering" => "Master of Engineering",
    "Bachelor of Science " => "Bachelor of Science",
    "MFA" => "Master of Fine Arts",
    "Bachelor of Arts in Architecture" => "Bachelor of Arts",
    "bachelor of science" => "Bachelor of Science",
    "bachelor of Science" => "Bachelor of Science",
    "Master Of Sciences" => "Master of Science",
    "Bachelor of Sciences" => "Bachelor of Science",
    "Computer Science B.A." => "Bachelor of Arts",
    "MASTER OF COMPUTER NETWORKING" => "Master of Science",
    "BS.c" => "Bachelor of Science",
    "Doctorate of computer science" => "PhD",
    "Master in Design Studies" => "Master of Design Studies",
    "Business Administration" => "Business Administration",
    "master" => "Master of Science",
    "Masters in Engineering Management" => "Master of Engineering Management",
    "Masters of Computer Science" => "Master of Science",
    "Masters of Business Administration" => "Master of Business Administration",
    "Pursuing BS" => "Bachelor of Science",
    "Masters of science " => "Master of Science",
    "computer science" => "Master of Science",
    "Phd." => "PhD",
    "Master of Planning" => "Master of Planning",
    "MASTER OF SCIENCE" => "Master of Science",
    "Master of Scienece" => "Master of Science",
    "MASTERS OF SCIENCE" => "Master of Science",
    "World Bachelor in Business" => "Bachelor of Business",
    "Master of Public Policy" => "Master of Public Policy",
    "Ph.D in Applied Mathematics" => "PhD",
    "Phd" => "PhD",
    "bachelor" => "Bachelors",
    "Computer Science" => "Master of Science",
    "Communication" => "Master of Science",
    "Bachelor's of science "  => "Bachelor of Science",
    "Bachelors of Arts and Sciences" => "Bachelor of Arts and Science",
    "Master in Electrical Engineering" => "Master of Science",
    "Master in Professional Accounting" => "Master of Professional Accounting",
    "CS" => "Master of Science",
    "International Relations Global Business" => "International Relations Global Business",
    "Masters of Science(Computer Science-Game Development)" => "Master of Science",
    "B.S. Electrical Engineering"  => "Bachelor of Science",
    "Master of Science-Applied Psychology" => "Master of Science",
    "Bachelor of Science in Business Administration" => "Bachelor of Science",
    "Master of Fine Arts" => "Master of Arts",
    "Masters CS" => "Master of Science",
    "Major: Business Admin Minor: Game Design & Management" => "Business Administration",
    "PhD " => "PhD",
    "Bachelor's of Science " => "Bachelor of Science",
    "B.Sc." => "Bachelor of Science",
    "Bachelor's Degree in Communication" => "Bachelor of Comunication",
    "B.A. International Relations" => "Bachelor of Arts",
    "Bachelor of Architecture" => "Bachelor of Architecture",
    "B.S" => "Bachelor of Science",
    "M.A Environmental Studies (in progress)" => "Master of Arts",
    "BA " => "Bachelor of Arts",
    "Bachelors of Art" => "Bachelor of Arts",
    "MS in CS" => "Master of Science",
    "BA - Political Science" => "Bachelor of Arts",
    "Bachelors " => "Bachelors",
    "Master in Construction Management" => "Master of Construction Management",
    "Ph.D. in Chemistry" => "PhD",
    "Master od Science" => "Master of Science",
    "Bachelors of Science in Computer Science" => "Bachelor of Science",
    "B.S. Computer Science & Games" => "Bachelor of Science",
    "Master of Finance" => "Master of Finance",
    "Bachelor of Science in Engineering" => "Bachelor of Science",
    "Ph.D," => "PhD",
    "Masters in computer science" => "Master of Science",
    "Undergraduate" => "Bachelor",
    "B.S. Computer Science" => "Bachelor of Science",
    "Master of Sicence" => "Master of Science"
};
def SanitizeDegree(degree)
  if DegreeMapping.include? degree
    return DegreeMapping[degree]
  else
    return degree
  end
end
users = User.where(:active => true).to_a;
school_users = users.select {|user| user[:_id].include? "@usc.edu"};
profiles = Profile.find(users.map{|user| user[:handle]});

total_count = school_users.count();

groups_by_date = school_users.select {|user| !user[:create_dttm].blank?}.sort_by{|user|user[:create_dttm]}.
                             group_by {|user| user[:create_dttm].strftime("Date.UTC(%Y,%m,%d)")};

groups_by_major = school_users.select {|user| !user[:major].blank?}.
    group_by {|user| user[:major]};

groups_by_degree_year = school_users.select {|user| !user[:year].blank? && !user[:degree].blank?}.
                        group_by {|user| [SanitizeDegree(user[:degree]), user[:year]]};

count = 0;
count_by_date = Hash[groups_by_date.map{|key, value| count += value.count(); [key, count]}];
count_by_major = Hash[groups_by_major.map{|key, value| [key, value.count()]}];
count_by_degree_year = Hash[groups_by_degree_year.map{|key, value| [key, value.count()]}];

work_ids = profiles.map{|profile| profile[:user_work_ids]}.flatten;
work_ids_count = profiles.select{|profile| !profile[:user_work_ids].blank? &&
                                            profile[:user_work_ids].count()>0}.count();
course_ids = profiles.map{|profile| profile[:user_course_ids]}.flatten;
internship_ids = profiles.map{|profile| profile[:user_internship_ids]}.flatten;
internship_ids_count = profiles.map{|profile| !profile[:user_internship_ids].blank? &&
                                               profile[:user_internship_ids].count()>0}.count();

courses_by_major = {};
users.each do |user|
  profile = Profile.find(user[:handle]);
  if profile.blank?
    next
  end
  if profile[:user_course_ids].blank?
    next
  end
  profile[:user_course_ids].each do |course_id|
    if course_id.nil?
      next
    end
    course = UserCourse.find(course_id);
    if user[:major].blank? || course.blank? || course[:title].blank?
      next
    end
    pair = [user[:major], course[:title]];
    if !courses_by_major.include? pair
      courses_by_major[pair] = 0;
    end
    courses_by_major[pair] += 1;
  end
end
courses_by_major = courses_by_major.select {|key,value| value > 1};

work_by_major = {};
users.each do |user|
  profile = Profile.find(user[:handle]);
  if profile.blank?
    next
  end
  if profile[:user_work_ids].blank?
    next
  end
  profile[:user_work_ids].each do |work_id|
    if work_id.blank?
      next
    end
    work = UserWork.find(work_id);
    if user[:major].blank? || work.blank? || work[:company].blank?
      next
    end
    pair = [user[:major], work[:company]]
    if !work_by_major.include? pair
      work_by_major[pair] = 0;
    end
    work_by_major[pair] += 1;
  end
end
work_by_major = work_by_major.select {|key,value| value > 1};

internships_by_major = {};
users.each do |user|
  profile = Profile.find(user[:handle]);
  if profile.blank?
    next
  end
  if profile[:user_internship_ids].blank?
    next
  end
  profile[:user_internship_ids].each do |internship_id|
    if internship_id.blank?
      next
    end
    internship = UserInternship.find(internship_id);
    if user[:major].blank? || internship.blank? || internship[:company].blank?
      next
    end
    pair = [user[:major], internship[:company]]
    if !internships_by_major.include? pair
      internships_by_major[pair] = 0;
    end
    internships_by_major[pair] += 1;
  end
end
internships_by_major = internships_by_major.select {|key,value| value > 1};

jobs_by_major = {};
users.each do |user|
  job_ids = JobApplicant.where(:handle=>user[:handle])
  if job_ids.blank?
    next
  end
  job_ids.each do |job_id|
    if job_id.blank?
      next
    end
    job = Job.find(job_id[:job_id]);
    if user[:major].blank? || job.blank? || job[:company].blank?
      next
    end
    pair = [user[:major], job[:company]]
    if !jobs_by_major.include? pair
      jobs_by_major[pair] = 0
    end
    jobs_by_major[pair] += 1;
  end
end
jobs_by_major = jobs_by_major.select {|key,value| value > 1};

#printing data
puts "<pre id=\"jobs_by_major\" style=\"display:none\">Major	Company	Count"
total = jobs_by_major.values().sum();
jobs_by_major.each {|key, value|
  if value == 1
    next
  end
  puts "#{key[0]}\t#{key[1]}\t#{(value*100.0/total).round(2)}%";
}
puts "</pre>"

#printing data
puts "<pre id=\"internships_by_major\" style=\"display:none\">Major	Company	Count"
total = internships_by_major.values().sum();
internships_by_major.each {|key, value|
  if value == 1
    next
  end
  puts "#{key[0]}\t#{key[1]}\t#{(value*100.0/total).round(2)}%";
}
puts "</pre>"

#printing data
puts "<pre id=\"work_by_major\" style=\"display:none\">Major	Company	Count"
total = work_by_major.values().sum();
work_by_major.each {|key, value|
  if value == 1
    next
  end
  puts "#{key[0]}\t#{key[1]}\t#{(value*100.0/total).round(2)}%";
}
puts "</pre>"

#printing data
puts "<pre id=\"course_by_major\" style=\"display:none\">Major	Course	Count"
total = courses_by_major.values().sum();
courses_by_major.each {|key, value|
  if value == 1
    next
  end
  puts "#{key[0]}\t#{key[1]}\t#{(value*100.0/total).round(2)}%";
}
puts "</pre>"

#printing data
puts "<pre id=\"count_by_degree_year\" style=\"display:none\">Degree	Year	Count"
total = count_by_degree_year.values().sum();
count_by_degree_year.each {|key, value|
  puts "#{key[0]}\t#{key[1]}\t#{(value*100.0/total).round(2)}%";
}
puts "</pre>"

puts '<script type="text/javascript">'
data_string = "["+count_by_date.map {|key, value| "[#{key}, #{value}]"}.join(",")+"]";
puts "var count_by_date=[{
          name: \"User Growth\",
          data: #{data_string}
      }]";
puts '</script>'

puts '<script type="text/javascript">'
data_string = "["+count_by_major.map {|key, value| "[\"#{key}\", #{(value*100.0/total).round(2)}]"}.join(",")+"]";
puts "var count_by_major=[{
          type: 'pie',
          name: \"Majors\",
          data: #{data_string}
      }]";
puts '</script>'