# Process data scrapped from universities and creates a clean list of students to be injested to User Model

filename = ARGV[0];
Valid_email_suffices = ["gatech.edu", 'u.washington.edu', 'cmu.edu', 'andrew.cmu.edu', 'ucla.edu']
Major_mapping = {
    'CE' => 'eng_comp',
    'CS' => 'sci_comp',
    'CSE' => 'eng_comp',
    'CSEE' => 'eng_comp',
    'ECE' => 'eng_electrical_electronics_communication',
    'EE' => 'eng_electrical',
    'Electrical & Computer Engr' => 'eng_comp',
    'School of Computer Science' => 'sci_comp',
    'COMPUTER SCIENCE & ENG' => 'eng_comp',
    'Computer Engineering' => 'eng_comp',
    'Computer Engineering (Bothell)' => 'eng_comp',
    'Computer Engineering and Systems' => 'eng_comp',
    'Computer Science' => 'sci_comp',
    'Computer Science & Engineering' => 'sci_comp',
    'Computer Science & Engineering (BS/MS)' => 'sci_comp',
    'Computer Science & Software Engineering' => 'eng_computer_software',
    'Computer Science and Systems' =>'sci_comp',
    'Electrical Engineering' => 'eng_electrical',
    'Electrical Engineering (Bothell)' => 'eng_electrical',
    'Electrical Engineering (Nanotechnology)' => 'eng_electrical',
    'Computer Science and Arts' => 'sci_comp',
    'Computer Science, Dietrich College Interdisciplinary' => 'sci_comp',
    'Computer Science, Engineering & Public Policy' => 'sci_comp',
    'Computer Science, English' => 'sci_comp',
    'Computer Science, History' => 'sci_comp',
    'Computer Science, Human-Computer Interaction' => 'sci_comp',
    'Computer Science, Mathematical Sciences' => 'sci_comp',
    'Computer Science, Modern Languages' => 'sci_comp',
    'Computer Science, Music' => 'sci_comp',
    'Computer Science, Philosophy' => 'sci_comp',
    'Computer Science, Physics' => 'sci_comp',
    'Computer Science, Psychology' => 'sci_comp',
    'Computer Science, Robotics' => 'sci_comp',
    'Computer Science, Statistics' => 'sci_comp',
    'ECE: Electrical & Computer Engineering' => 'eng_comp',
    'Electrical & Computer Engineering' => 'eng_comp',
    'Electrical & Computer Engineering, Biological Sciences' => 'eng_comp',
    'Electrical & Computer Engineering, Biomedical Engineering' => 'eng_comp',
    'Electrical & Computer Engineering, CIT Interdisciplinary' => 'eng_comp',
    'Electrical & Computer Engineering, Computer Science' => 'eng_comp',
    'Electrical & Computer Engineering, Economics' => 'eng_comp',
    'Electrical & Computer Engineering, Engineering & Public Policy' => 'eng_comp',
    'Electrical & Computer Engineering, Engineering & Public Policy, Social & Decision Sciences' => 'eng_comp',
    'Electrical & Computer Engineering, English' => 'eng_comp',
    'Electrical & Computer Engineering, History, Computer Science' => 'eng_comp',
    'Electrical & Computer Engineering, Human-Computer Interaction' => 'eng_comp',
    'Electrical & Computer Engineering, Machine Learning' => 'eng_comp',
    'Electrical & Computer Engineering, Modern Languages' => 'eng_comp',
    'Electrical & Computer Engineering, Music' => 'eng_comp',
    'Electrical & Computer Engineering, Philosophy' => 'eng_comp',
    'Electrical & Computer Engineering, Physics' => 'eng_comp',
    'Electrical & Computer Engineering, Robotics' => 'eng_comp',
    'Electrical & Computer Engineering, Social & Decision Sciences, Computer Science' => 'eng_comp',
    'Machine Learning' => 'sci_comp',
    'Software Engineering' => 'eng_computer_software',
}

Degree_mapping = {
    "doctoral" => "PhD",
    'freshman' => 'Bachelor - Freshman',
    'junior' => 'Bachelor - Junior',
    'senior' => 'Bachelor - Senior',
    'sophomore' => 'Bachelor - Sophomore',
    'masters' => 'Master',
    'grad student' => 'Master',
    'graduate' => 'Master',
    'graduate student' => 'Master',
    'phd student' => 'PhD',
}

Year_mapping = {
    'PhD' => nil,
    'Bachelor - Freshman' => '2018',
    'Bachelor - Sophomore' => '2017',
    'Bachelor - Junior' => '2016',
    'Bachelor - Senior' => '2015',
}

def valid_email(email)
  if email.blank?
    return false
  end
  suffix = ''
  unless !email.include? '@'
    suffix = email.split('@')[1];
  end
  return Valid_email_suffices.include? suffix;
end

def get_major_id(major)
  if major.blank?
    return nil
  end

  if !Major_mapping.has_key? major
    return nil
  end

  return Major_mapping[major];
end

def get_degree(degree)
  if degree.blank?
    return nil
  end
  degree = degree.downcase();
  if Degree_mapping.has_key? degree
    return Degree_mapping[degree]
  else
    return nil
  end
end

def get_year(degree)
  if degree.blank?
    return nil
  end

  if Year_mapping.has_key? degree
    return Year_mapping[degree];
  else
    return nil;
  end
end

fh = File.open(filename, 'r');
userid_hash = {}
fh.readlines().each do |line|
  cols = line.strip().split("\t");
  name = cols[0]
  email = cols[1]
  user_id = cols[2]
  major = cols[3]
  degree = get_degree(cols[4])
  university_name = cols[5]
  year = cols[6]
  # overriding year
  year = get_year(degree)
  major_id = get_major_id(major);
  unless !(valid_email(email) && !major_id.blank?)
    if !userid_hash.has_key? user_id
      userid_hash[user_id] = true;
      puts "#{name}\t#{email}\t#{major_id}\t#{degree}\t#{year}"
    end
  end

  # output even if major_id is false if its ucla
  if (valid_email(email) && major_id.blank? && email.ends_with?('ucla.edu'))
    if !userid_hash.has_key? user_id
      userid_hash[user_id] = true;
      puts "#{name}\t#{email}\t#{major_id}\t#{degree}\t#{year}"
    end
  end
end