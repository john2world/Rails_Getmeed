module NotifierHelper
  include LinkHelper

  def is_default_file_image(image_url)
    DEFAULT_CLOUDINARY_IDS.each do |image|
      if image_url.include? image
        return true
      end
    end
    return false
  end

  def get_company_hiring_trend(college, major)
    college_hiring_data = CompanyHiringInsights.where(:school_id => college);
    hiring_data = {}
    college_hiring_data.each do |data|
      if !hiring_data.has_key? data[:company_id]
        hiring_data[data[:company_id]] = {}
      end
      val = data[:major_counts].select{|major_count| major.include? major_count['major']};
      unless val.blank? || val.count() == 0
        hiring_data[data[:company_id]][data[:year]] = val.map{|major| major['count']}.sum()
      end
    end

    company_hiring_data = {}
    hiring_data.each do |key, values|
      company_hiring_data[key] = values.values.sum()
    end

    year_hiring_data = {}
    hiring_data.each do |year, year_values|
      year_values.each do |year, count|
        if !year_hiring_data.has_key? year
          year_hiring_data[year] = 0
        end
        year_hiring_data[year] += count
      end
    end
    total_sum = company_hiring_data.values().sum()

    company_trend_data = []
    company_hiring_data.each do |company, company_count|
      dict = {}
      dict[:company_id] = company
      dict[:hiring_share] = (company_count*100/total_sum).to_i
      unless hiring_data[company].blank? || hiring_data[company][2013].blank? || hiring_data[company][2012].blank?
        trend = (hiring_data[company][2013] * 100/year_hiring_data[2013]).to_i - (hiring_data[company][2012] * 100/year_hiring_data[2012]).to_i
      end
      dict[:trend] = trend
      company_trend_data.push(dict)
    end

    company_trend_data.each do |company|
      company_meta = Company.find(company[:company_id])
      unless company_meta.blank?
        company[:name] = company_meta[:name]
      end
    end

    return company_trend_data
  end

  def check_email_notification_eligibility(user, type=nil)
    if user.class.to_s.eql? 'EnterpriseUser'
      return true
    end

    if user.blank? || user.active == false
      return false
    end
    unless type.blank?
      user_settings = UserSettings.find(user.handle)
      if !user_settings.blank? and !user_settings.email_notification_subscription_enabled(type)
        return false
      end
    end
    true
  end

end