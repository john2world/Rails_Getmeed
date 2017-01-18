class SchoolsStore
  def self.get_majors_from_select(majors_list)
    if majors_list.class == String
      majors_list = majors_list.split(", ")
    end
    majors = []
    majors_list.each do |major|
      if major == 'all'
        majors.concat(admin_all_majors.pluck(:code))
      elsif major.starts_with? 'all_'
        majors.concat(get_majors_from_type(major.gsub('all_', '')).map{|m| m[:code]})
      else
        majors.push(major)
      end
    end
    return majors
  end

  def self.admin_all_schools
    @schools = School.all
    @filter_schools = Array.new
    @schools.each do |school|
      unless school[:_id].eql? 'tester' or school[:_id].eql? 'metester'
        @filter_schools << school
      end
    end
    @filter_schools
  end

  def self.get_schools_from_select(school_ids)
    if school_ids.include? "all"
      schools = admin_all_schools
      return schools.map{|school| school.handle}
    else
      return school_ids
    end
  end
end
