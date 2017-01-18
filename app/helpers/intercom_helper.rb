module IntercomHelper
  include IntercomManager
  include JobsManager
  include CommonHelper

  IntercomClient = Intercom::Client.new(app_id: ENV['intercom_app_id'], api_key: ENV['intercom_secret'])

  Schools = ["berkeley", "brown", "caltech", "cmu", "columbia", "cornell", "duke", "gatech", "harvard", "illinois",
             "mit", "northwestern", "nyu", "princeton", "rice", "stanford", "uci", "ucsd", "ucla", "ufl", "umass",
             "umich", "upenn", "usc", "utexas", "uwaterloo", "uw", "yale"]

  BucketSizeMapping = {
      "jobs" => {"all" => 300},
      "exp_1" => {"all" => 50},
      "exp_2" => {"all" => 50},
      "exp_3" => {"all" => 50},
  }
  SchoolSegmentMapping = {
      "berkeley"=>"560f036a52a51adbaf0000a1",
      "brown"=>"560f057452a51adbed0000d5",
      "caltech"=>"560f07558e93efc8400000be",
      "cmu"=>"560f05d5f02979e07500003e",
      "columbia"=>"560f06f5f02979e2d900006a",
      "cornell"=>"560f07638e93efc47b0000bd",
      "duke"=>"560f03988e93efc77d0000cf",
      "gatech"=>"560f078252a51adbed000102",
      "harvard"=>"560f0582ecf7db1c100000d0",
      "illinois"=>"560f07b752a51add150000d2",
      "mit"=>"560f03d052a51adab10000a4",
      "northwestern"=>"560f03ebf02979e0c300004d",
      "nyu"=>"560f05c4d428ee8e1c0000d5",
      "princeton"=>"560f07cde78243f722000111",
      "rice"=>"560f04eb52a51adcc8000091",
      "stanford"=>"560f033e52a51adbaf0000a0",
      "uci"=>"560f07ea8e93efc8400000c5",
      "ucla"=>"560f0382d428ee8af50000de",
      "ucsd"=>"560f072cecf7db1c800000e0",
      "ufl"=>"560f045f8e93efc4d40000b6",
      "umass"=>"560f04feecf7db1a63000072",
      "upenn"=>"560f05a8d428ee8e1c0000d4",
      "usc"=>"560f0472f02979e075000037",
      "utexas"=>"560f0444e78243f6c90000df",
      "uw"=>"560f04d98e93efc8400000a2",
      "uwaterloo"=>"560f062decf7db18ce000082",
      "yale"=>"560f05f1e78243f7220000f7",
  }

  CustomMajorIdMappings = {
      "Electrical and Computer Engineering"=>"sci_electrical_and computer engineering",
      "Civil and Environmental Engineering"=>"eng_civil_environmental",
      "Operations Research and Information Engineering"=>"eng_opers_rsch_info",
      "ECE"=>"sci_electrical_and computer engineering",
      "Mechanical Science and Engineering"=>"eng_mechanical",
      "Aerospace Engineering"=>"eng_aero_mech",
      "Biological Engineering"=>"sci_bioengineering",
      "Center For Real Estate Develop"=>"sci_real_estate development",
      "Civil And Environmental Eng"=>"eng_civil_environmental",
      "Electrical Eng And Computer Sci"=>"eng_electrical_engineering_and_computer_science",
      "Materials Science And Eng."=>"bachelor of science_materials science and nano engineering",
      "Nuclear Science And Engineering"=>"eng_nuclear_engineering",
      "Operations Research"=>"sci_opers_rsch_mgmt",
      "Urban Studies And Planning"=>"jun_urban_studies",
      "Aeronautics And Astronautics"=>"eng_aero_mech",
      "Linguistics And Philosophy"=>"soc_linguistics",
      "Art"=>"Arts and Humanities",
      "Humanities and Arts"=>"Arts and Humanities",
      "Biological Sciences"=>"Biology",
      "Tepper School of Business"=>"Business",
      "Tepper School of Business Flex-Time"=>"Business",
      "Chemical Engineering"=>"Chemical Engineering and Materials Science",
      "Materials Science And Engineering"=>"Chemical Engineering and Materials Science",
      "Civil And Environmental Engineering"=>"Civil Engineering",
      "Robotics Institute"=>"Computer Science",
      "NREC: National Robotics Engineering Center"=>"Computer Science",
      "Machine Learning"=>"Computer Science",
      "Computer Science and Arts"=>"Computer Science",
      "Design"=>"Design and Applied Arts",
      "Human-Computer Interaction"=>"Human Computer Interaction",
      "Information Systems"=>"Information Systems Management",
      "Information Systems:Sch of IS And Mgt"=>"Information Systems Management",
      "Mathematical Sciences"=>"Mathematics",
      "Public Policy And Mgt:Sch of Pub Pol And Mgt"=>"Public Policy Planning And Development",
      "American Studies And Ethnicity (Chicano/Latino Studies)"=>"American Studies",
      "Animation and Digital Arts"=>"Animation",
      "Chemical Engineering (Biochemical Engineering)"=>"Biochemical Engineering",
      "Biomedical Engineering (Biochemical Engineering)"=>"Biochemical Engineering",
      "Business Administration (Cinematic Arts)"=>"Business Administration",
      "Business Administration - World"=>"Business Administration",
      "Chemical Engineering (Petroleum Engineering)"=>"Chemical Engineering",
      "Civil Engineering (Building Science)"=>"Civil Engineering",
      "Applied and Computational Mathematics"=>"Computational And Applied Math",
      "Computer Engineering And Computer Science"=>"Computer Engineering",
      "Computer Science/Business Administration"=>"Computer Science",
      "Economics/Mathematics"=>"Economics",
      "Engineering (Environmental Engineering)"=>"Environmental Engineering",
      "International Relations (Global Business)"=>"International Relations",
      "Social Work"=>"Master Of Social Work",
      "Molecular Biology"=>"Molecular and Cell Biology",
      "Policy Planning and Development"=>"Public Policy, Planning, And Development",
      "Theatre"=>"Theater, Dance, and Performance Studies",
      "Theatre (Acting)"=>"Theater, Dance, and Performance Studies",
  }

  SchoolIpMapping = {
      "berkeley"=>"169.229.216.200",
      "duke"=>"152.3.43.156",
      "gatech"=>"130.207.160.173",
      "mit"=>"23.220.69.91",
      "harvard"=>"65.112.8.5",
      "northwestern"=>"129.105.247.81",
      "princeton"=>"140.180.223.22",
      "rice"=>"128.42.204.44",
      "ucsd"=>"132.239.180.101",
      "ufl"=>"128.227.9.48",
      "illinois"=>"192.17.13.36",
      "umass"=>"128.119.103.148",
      "usc"=>"128.125.253.136",
      "umich"=>"141.211.243.44",
      "uw"=>"209.124.188.133",
      "brown"=>"131.109.200.2",
      "caltech"=>"131.215.239.141",
      "cmu"=>"128.2.42.10",
      "columbia"=>"128.59.105.24",
      "cornell"=>"128.253.222.174",
      "nyu"=>"128.122.1.6",
      "stanford"=>"171.67.215.200",
      "uci"=>"137.164.23.93",
      "ucla"=>"128.97.27.37",
      "upenn"=>"50.191.245.52",
      "utexas"=>"4.59.32.37",
      "uwaterloo"=>"216.191.167.38",
      "yale"=>"130.132.35.53",
  }

  Tags = IntercomClient.tags.all();
  Segments = IntercomClient.segments.all();

  def get_segment_by_name(name)
    return Segments.select{|segment| segment.name == name}.first
  end

  def get_tag_by_name(name)
    return Tags.select{|tag| tag.name == name}.first
  end

  def get_major_from_custom_rules(major_text)
    major_id = CustomMajorIdMappings[major_text.downcase]
    if major_id.blank?
      return nil
    end
    return Major.find(major_id)
  end

  def set_custom_attributes_by_major(custom_attributes, major)
    if major.blank?
      return
    end
    custom_attributes["major_text"] = major.major
    custom_attributes["Major"] = major.major
    custom_attributes["major_id"] = major.code
    if major.major_type_id.blank?
      return
    end
    major_type = MajorType.find(major.major_type_id)
    if major_type.blank?
      return
    end
    custom_attributes["Major_Type"] = major_type.name
    custom_attributes["major_type_id"] = major_type.major_type_id
  end

  def populate_major_text(contact)
    custom_attributes = contact.custom_attributes;
    # if custom attributes already has major_text .. not need to populate
    if custom_attributes.has_key? "major_text"
      return contact
    end
    # first attempt to see if the major field has id in it
    major_text = custom_attributes["major"]
    unless major_text.blank?
      major = Major.find(major_text)
      if major.blank?
        major = Major.find_by(major: major_text)
      end
      unless major.blank?
        # found a major and hence populate all the other necessary attributes
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
    end
    # second attend to see if the Major field has a text that is same as Major
    major_text = custom_attributes['Major']
    unless major_text.blank?
      major_text = major_text.gsub('&amp;', 'And')
      major = Major.find_by(major: major_text)
      unless major.blank?
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
      # if major is blank and it is not parsable. See if it can be parsed by rules
      major = get_major_from_custom_rules(major_text)
      unless major.blank?
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
    end
    # from major_id_text
    major_id_text = custom_attributes['major_id']
    unless major_id_text.blank?
      major = Major.find(major_id_text)
      unless major.blank?
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
    end
    major_text = custom_attributes['Major Type']
    unless major_text.blank?
      major_text = major_text.gsub('&amp;', 'And')
      major = Major.find_by(major: major_text)
      unless major.blank?
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
      # if major is blank and it is not parsable. See if it can be parsed by rules
      major = get_major_from_custom_rules(major_text)
      unless major.blank?
        set_custom_attributes_by_major(custom_attributes, major)
        contact.custom_attributes = custom_attributes
        return contact
      end
    end
    return contact
  end

  def get_contacts_by_segment(name, limit = DailyLimit)
    segment = get_segment_by_name(name)
    if segment.blank?
      return nil
    end
    return IntercomClient.users.find_all({:segment_id => segment.id}).take(limit);
  end

  def get_contacts_by_tag(tagname, limit = DailyLimit)
    tag = get_tag_by_name(tagname)
    if tag.blank?
      return nil
    end
    return IntercomClient.users.find_all({:tag_id => tag.id}).take(limit)
  end

  def populate_latest_job_info(contact, school)
    custom_attributes = contact.custom_attributes
    # get a random job from top 10 jobs but not gigs
    # if major type id is missing we skip
    if custom_attributes['major_type_id'].blank?
      return
    end
    if custom_attributes.has_key? 'year'
      #year = Date.today.year
      # for now no year just return
      return
    else
      year = custom_attributes['year'].to_i
    end
    top_job = nil
    top_jobs = get_top_applied_jobs(custom_attributes['major_type_id'], year, false, false)
    if !top_jobs.blank? && top_jobs.count() > 0
      top_job = top_jobs.take(5).sample
    end
    unless top_job.blank?
      if top_job.type == "intern" || top_job.type == "Internship"
        custom_attributes['latest_internship_title'] = top_job.title
        custom_attributes['latest_internship_company'] = top_job.company
        custom_attributes['latest_internship_location'] = top_job.location
        custom_attributes['latest_internship_description'] = sanitize_group_description(top_job.description).truncate(200)
        custom_attributes['latest_internship_url'] = top_job.job_url
      else
        custom_attributes['latest_job_title'] = top_job.title
        custom_attributes['latest_job_company'] = top_job.company
        custom_attributes['latest_job_location'] = top_job.location
        custom_attributes['latest_job_description'] = sanitize_group_description(top_job.description).truncate(200)
        custom_attributes['latest_job_url'] = top_job.job_url
      end
    end
    contact.custom_attributes = custom_attributes
  end

  def populate_latest_gig_info(contact, school)
    custom_attributes = contact.custom_attributes
    top_gig = get_top_gigs(10, school, custom_attributes['major_type_id'], custom_attributes['year']).sample
    unless top_gig.blank?
      custom_attributes['latest_gig_title'] = top_gig.title
      custom_attributes['latest_gig_description'] = sanitize_group_description(top_gig.description).truncate(200)
      custom_attributes['latest_gig_url'] = top_gig.job_url
      custom_attributes['latest_gig_skill'] = top_gig.skills.first
      custom_attributes['latest_gig_pay'] = top_gig.fixed_compensation
    end
  end

  def clean_first_name(first_name, email)
    if first_name.blank?
      return nil
    else
      unless email.blank?
        id = email.split('@')[0]
      end
      if first_name == id
        return nil
      else
        return first_name.split(' ')[0]
      end
    end
  end
  def clean_full_name(name, email)
    if name.blank?
      return nil
    else
      unless email.blank?
        id = email.split('@')[0]
      end
      if name == id
        return nil
      else
        names = name.split(', ')
        last_name = clean_first_name(names[0], email).titleize
        first_name = clean_first_name(names[1], email).titleize
        return "#{last_name}, #{first_name}"
      end
    end
  end

  def clean_contact_name(contact)
    custom_attributes = contact.custom_attributes
    if contact.name.blank?
      return
    end
    if !contact.name.include? ','
      custom_attributes['first_name'] = contact.name.titleize
      contact.custom_attributes = custom_attributes
      return
    end
    if contact.name.ends_with? ', '
      custom_attributes['first_name'] = contact.name.split(', ')[0].titleize
      contact.custom_attributes = custom_attributes
      return
    end
    full_name = clean_full_name(contact.name, contact.email)
    unless full_name.blank?
      contact.name = full_name
      names = full_name.split(', ')
      unless names.count() > 0
        custom_attributes['last_name'] = names[0].titleize
      end
      unless names.count() > 1 and !names[1].blank?
        custom_attributes['first_name'] = names[1].titleize
      end
      contact.custom_attributes = custom_attributes
    end
  end

  def get_count_by_school_bucket(bucket, school)
    if !BucketSizeMapping.has_key? bucket
      return 0
    end
    if BucketSizeMapping[bucket].has_key? school
      return BucketSizeMapping[bucket][school]
    else
      return BucketSizeMapping[bucket]['all']
    end
  end

  def update_contact_info(contact)
    school = get_school_handle_from_email(contact.email)
    contact = populate_major_text(contact)
    # if the last seen ip is missing populate it
    # if contact.last_seen_ip.blank?
    #   ip = SchoolIpMapping[school]
    #   unless ip.blank?
    #     contact.last_seen_ip = ip
    #   end
    # end

    # populate the latest job details
    #populate_latest_job_info(contact, school)

    #populate_latest_gig_info(contact, school)

    # clean name
    clean_contact_name(contact)

    custom_attributes = contact.custom_attributes
    custom_attributes["school"] = school.upcase
    custom_attributes["school_id"] = school
    custom_attributes.delete_if {|k,v| v.blank?}
    contact.custom_atrributes = custom_attributes
    IntercomClient.contacts.save(contact)
  end
end