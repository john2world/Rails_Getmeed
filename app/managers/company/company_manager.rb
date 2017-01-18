module CompanyManager
  include JobsHelper
  include PhotoManager

  def get_recommended_companies(user)
    Company.find(%w(apple quora microsoft twitter facebook salesforce))
  end

  def get_all_companies
    Company.all.to_a
  end

  def create_company_by_name(company_name)
    new_company_id = generate_id_from_text(company_name)
    company = Company.new
    company.name = company_name
    company.company_id = new_company_id
    company.id = new_company_id
    company.save
    return company
  end

  def get_or_create_company_ids(company_ids)
    new_company_ids = []
    company_ids.each do |company_id|
      company = Company.find(company_id)
      if company.blank?
        company = create_company_by_name(company_id)
        new_company_ids <<  company.id
      else
        new_company_ids << company_id
      end
    end
    new_company_ids
  end

  def get_or_create_company_by_id(company_id)
    company = Company.find(company_id)
    if company.blank?
      company = create_company_by_name(company_id)
    end
    return company
  end

  def get_company_by_name(company_name)
    # case insensitive match
    if company_name.blank?
      return nil
    end
    regex_pattern = Regexp.quote(company_name)
    Company.find_by(name: /^#{regex_pattern}$/i)
  end

  def get_company_by_name_exact(company_name)
    regex_pattern = Regexp.quote(company_name)
    Company.find_by(name: /^#{regex_pattern}$/i)
  end

  def get_or_create_company_by_name(company_name)
    if company_name.blank?
      return nil
    end
    company = get_company_by_name_exact(company_name)
    if company.blank?
      # create a new company
      company = create_company_by_name(company_name)
    end
    company
  end

  def get_companies_by_names(company_names)
    companies = company_names.map{|name| get_or_create_company_by_name(name)}
    photo_ids = Array.[]
    companies.each do |company|
      photo_ids << company.culture_photo_ids
    end
    photos = get_photos_by_ids(photo_ids)
    photo_map = Hash.new
    photos.each do |photo|
      photo_map[photo.id] = photo
    end

    companies.each do |company|
      company_photos = Array.[]
      unless company.culture_photo_ids.blank?
        company.culture_photo_ids.each do |photo_id|
          company_photos << photo_map[photo_id]
        end
        company[:photos] = company_photos
      end

    end
  end

  def search_company_by_string(string, limit = 10)
    regex_pattern = Regexp.quote(string)
    Company.where(name: /#{regex_pattern}/i).to_a
  end
end