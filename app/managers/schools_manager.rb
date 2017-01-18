module SchoolsManager


  def admin_all_schools
    @schools = School.all
    @filter_schools = Array.new
    @schools.each do |school|
      unless school[:_id].eql? 'tester' or school[:_id].eql? 'metester'
        @filter_schools << school
      end
    end
    @filter_schools
  end

  def get_social_channels_for_school(school_id)
    school_channels = SocialChannels.where(:school_handle => school_id).to_a
    school_channels.concat SocialChannels.where(:school_handle => 'everyone').to_a
    school_channels
  end

  def admin_all_topics
    PostTopic.where(:privacy => 'everyone').to_a
  end

  def get_topic_map(topic_ids)
    topics = PostTopic.find(topic_ids)
    topic_map = Hash.new
    topics.each do |topic|
      topic_map[topic.id] = topic
    end
    topic_map
  end

  def get_engineering_major_types
    major_type_map = Hash.new
    major_types = MajorType.where(:broad_classification => 'engineering')
    major_types.each do |major_type|
      major_type_map[major_type.id] = major_type
    end
    major_type_map
  end

  def get_business_major_types
    major_type_map = Hash.new
    major_types = MajorType.where(:broad_classification => 'business')
    major_types.each do |major_type|
      major_type_map[major_type.id] = major_type
    end
    major_type_map
  end

  def get_other_major_types
    major_type_map = Hash.new
    major_types = MajorType.where(:broad_classification => 'others')
    major_types.each do |major_type|
      major_type_map[major_type.id] = major_type
    end
    major_type_map
  end

  def get_all_major_types
    business     = get_business_major_types
    engineering  = get_engineering_major_types
    other        = get_other_major_types
    all_major_ids = business.keys
    all_major_ids += engineering.keys
    all_major_ids += other.keys
    ret = {
      business_major_types: get_business_major_types,
      engineering_major_types: get_engineering_major_types,
      other_major_types: get_other_major_types,
      all_major_ids: all_major_ids
    }
    ret
  end

  def admin_all_major_types
    major_type_map = Hash.new
    major_types = MajorType.all.sort_by {|m| m[:name].downcase}
    major_types.each do |major_type|
      major_type_map[major_type.id] = major_type
    end
    major_type_map
  end

  def get_majors_from_types(types)
    major_types = MajorType.find(types)
    major_ids = Array.new
    major_types.each do |type|
      major_ids.concat type.major_ids
    end
    major_ids
  end

  def get_majors_from_type(type)
    major_type = MajorType.find(type)
    major_type.major_ids
  end

  def get_major_type_from_major_id(major_id)
    major_type = MajorType.find_by(major_ids: major_id)
    return major_type
  end

  def admin_all_majors
    Major.where(:major.exists => true).to_a
  end

  def get_major_by_code(code)
    Major.find_by(:code => code)
  end

  def get_majors_for_ids(id)
    Major.find(id)
  end

  def get_major_by_name(name)
    Major.find_by(major: name)
  end

  def create_major(degree, major_text)
    if major_text.blank? || degree.blank?
      return nil
    end
    suffix = major_text.downcase.tr('', '_')
    prefix = degree.downcase.tr('', '_')
    major = Major.new
    major[:_id] = "#{prefix}_#{suffix}"
    major[:code] = "#{prefix}_#{suffix}"
    major[:major] = major_text.titleize
    major.save
    major
  end

  def get_major_type_by_id(major_type_id)
    MajorType.find(major_type_id)
  end

  def get_major_type_by_major_id(major_id)
    if major_id.blank?
      return nil
    end
    major = Major.find_by(:code => major_id)
    if major.blank?
      return
    end
    return major.major_type_id
  end

  def create_school(school_id, school_name)
    school = School.new
    school.id = school_id
    school.handle = school_id
    school.name = school_name
    # making new school active by default
    school.active = true
    school.save
    return school
  end

  def update_school_name(school, name)
    school.name = name.titleize
    school.save
    return school
  end
end