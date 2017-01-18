module CompanyHelper
  include CompanyManager
  ClearbitIndustryMapping = {
      'Media' => ['Business','Communications','Economics','Film, Video, & Audio Production','Humanities','Journalism','Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies'],
      'Automobiles' => ['Other Engineering','Hardware Engineering', 'Business', 'Economics', 'Product and Design'],
      'Distributors' => ['Business','Communications','Economics','Humanities','Journalism','Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', 'Mathematics', 'Data'],
      'Household Durables' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', 'Natural Sciences', 'Other Engineering'],
      'Hotels, Restaurants & Leisure' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Auto Components' => ['Other Engineering','Hardware Engineering', 'Product and Design'],
      'Leisure Products' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Speciality Retail' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Internet & Catalog Retail' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Multiline Retail' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Food Products' => ['Business','Communications','Economics','Humanities', 'Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies', ],
      'Oil, Gas & Consumable Fuels' => ['Other Engineering','Hardware Engineering', 'Natural Sciences'],
      'Energy Equipment & Services' => ['Other Engineering','Hardware Engineering', 'Natural Sciences'],
      'Banks' => ['Business', 'Economics', 'Mathematics', 'Data'],
      'Capital Markets' => ['Business', 'Economics', 'Mathematics', 'Data'],
      'Insurance' => ['Mathematics','Data','Economics','Business'],
      'Real Estate Investment Trusts' => ['Mathematics','Data','Economics','Business'],
      'Consumer Finance' => ['Mathematics','Data','Economics','Business'],
      'Thrifts & Mortgage Finance' => ['Mathematics','Data','Economics','Business'],
      'Health Care Providers & Services' => ['Mathematics','Data','Economics','Business', 'Social Sciences', 'Natural Sciences', 'Health and Medicine'],
      'Biotechnology' => ['Natural Sciences', 'Other Engineering','Hardware Engineering', 'Software Engineering', 'Health and Medicine'],
      'Pharmaceuticals' => ['Natural Sciences', 'Health and Medicine'],
      'Health Care Equipment & Supplies' => ['Natural Sciences', 'Other Engineering','Hardware Engineering', 'Software Engineering', 'Health and Medicine'],
      'Professional Services' => ['Business','Communications','Economics','Humanities','Journalism','Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies'],
      'Aerospace & Defense' => ['Natural Sciences', 'Other Engineering','Hardware Engineering', 'Software Engineering'],
      'Construction & Engineering' => ['Natural Sciences', 'Other Engineering','Hardware Engineering', 'Software Engineering'],
      'Electrical Equipment' => ['Other Engineering','Hardware Engineering', 'Software Engineering'],
      'Building Products' => ['Other Engineering','Hardware Engineering', 'Software Engineering', 'Product and Design'],
      'Airlines' => ['Natural Sciences', 'Other Engineering','Hardware Engineering', 'Software Engineering'],
      'Machinery' => ['Other Engineering','Hardware Engineering', 'Product and Design'],
      'Marine' => ['Natural Sciences'],
      'Road & Rail' => ['Other Engineering','Hardware Engineering'],
      'IT Services' => ['Hardware Engineering', 'Software Engineering'],
      'Software' => ['Software Engineering', 'Product and Design'],
      'Technology Hardware, Storage & Peripherals' => ['Other Engineering','Hardware Engineering'],
      'Electronic Equipment, Instruments & Components' => ['Other Engineering','Hardware Engineering'],
      'Communications Equipment' => ['Other Engineering','Hardware Engineering'],
      'Semiconductors & Semiconductor Equipment' => ['Other Engineering','Hardware Engineering'],
      'Construction Materials' => ['Other Engineering', 'Natural Sciences'],
      'Chemicals' => ['Natural Sciences', 'Other Engineering', 'Health and Medicine'],
      'Metals & Mining' => ['Natural Sciences', 'Other Engineering', ],
      'Advertisting' => ['Business','Communications','Economics','Film, Video, & Audio Production','Humanities','Journalism','Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies'],
      'Movies & Entertainment' => ['Business','Communications','Economics','Film, Video, & Audio Production','Humanities','Journalism','Marketing','Social Sciences','Languages','Global, Ethnic, Culture & Gender Studies'],
      'Systems Software' => ['Software Engineering'],
      'Application Software' => ['Software Engineering', 'Product and Design']
  }
  def clearbit_to_company(clearbit_hash)
    if clearbit_hash.blank?
      return
    end
    # check if a company already exists with that name
    company = get_company_by_name(clearbit_hash['name'])
    if company.blank?
      # create a new company
      company = Company.new()
    end

    company.name = clearbit_hash['name']
    if company.company_id.blank?
      company.company_id = generate_id_from_text(company.name)
      company.id = company.company_id
    end

    if company.company_logo.blank?
      begin
        company.company_logo = convert_to_cloudinary(clearbit_hash['logo'], 100, 100, company.company_id)
      rescue
      end
    end
    company.description = clearbit_hash['description']
    company.location = clearbit_hash['location']
    metadata = company.meta_data
    metadata["clearbit_id"] = clearbit_hash['id']
    metadata['clearbit_tags'] = clearbit_hash['tags']
    majors = []
    unless clearbit_hash['tags'].blank?
      clearbit_hash['tags'].each do |tag|
        if ClearbitIndustryMapping[tag].blank?
          # try if it directly matches the major
          major = get_major_by_name(tag)
          unless major.blank?
            majors.append(major)
          end
        else ClearbitIndustryMapping[tag].blank?
          majors.concat(ClearbitIndustryMapping[tag])
        end
      end
    end
    metadata['clearbit_category'] = clearbit_hash['category']
    metadata['url'] = clearbit_hash['url']
    unless clearbit_hash['category'].blank?
      category = clearbit_hash['category']['industry']
      unless ClearbitIndustryMapping[category].blank?
        majors.concat(ClearbitIndustryMapping[category])
      end
    end
    major_ids = majors.uniq.map{|major| get_major_by_name(major)}.select{|m| !m.blank?}.map{|m| m.code}.compact;
    company.target_majors = major_ids
    unless clearbit_hash['facebook'].blank?
      metadata['facebook_handle'] = clearbit_hash['facebook']['handle']
    end
    unless clearbit_hash['linkedin'].blank?
      metadata['linkedin_handle'] = clearbit_hash['linkedin']['handle']
    end
    unless clearbit_hash['twitter'].blank?
      metadata['twitter_handle'] = clearbit_hash['twitter']['handle']
    end
    unless clearbit_hash['metrics'].blank?
      metadata['metrics'] = clearbit_hash['metrics']
    end
    company.meta_data = metadata
    company.save
    return company
  end

end