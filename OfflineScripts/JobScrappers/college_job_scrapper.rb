require 'csv'
require 'thread'
require 'thread/pool'

ThreadPoolLimit = 5
CollegeJobMajorMapping = './OfflineScripts/JobScrappers/college_job_major_mapping.tsv'
CompaniesDump = './OfflineScripts/JobScrappers/college_job_companies.txt'
JobsDump = './OfflineScripts/JobScrappers/college_job_jobs.txt'
CollegeJobMajorMapping = './OfflineScripts/JobScrappers/college_job_major_mapping.tsv'

ExploreApiUrl = 'https://www.aftercollege.com/ajax/explore_api_proxy.ashx'
MetaParamsUrl = 'https://www.aftercollege.com/explore/'
BaseUrl = 'https://www.aftercollege.com'
ApplyJobUrl = 'https://www.aftercollege.com/apply_job/?jobid=%s'
SignInUrl = 'https://www.aftercollege.com/useraccount/signin/'
SchoolSearchUrl = 'https://www.aftercollege.com/ajax/schoolsearch.aspx?query=%s&is_return_json=true'
SignInForm = {"Email" => "viswamani@outlook.com",
              "password" => "MeedLover"}

Headers = {"Cache-Control" => "max-age=0",
           "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
           "Upgrade-Insecure-Requests" => "1",
           "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36",
           "Content-Type" => "application/x-www-form-urlencoded",
           "Accept-Encoding" => "gzip, deflate",
           "Accept-Language" => "en-US,en;q=0.8",
}

JobDayCount = 60

GraduationDate = Date.today() + 3.month
JobDetailsUrl = 'https://www.aftercollege.com/job/%s/'
Cookies = nil
SchoolsList = [
    "University of Southern California",
    "University of California, Los Angeles",
    "University of California, Berkeley",
    "University of Florida",
    "Northwestern University",
    "Stanford University",
    "Massachusetts Institute of Technology",
    "Rice University",
    "Brown University",
    "Duke University",
    "Harvard University",
    "Columbia University",
    "Carnegie Mellon University",
    "New York University",
    "Yale University",
    "University of Washington",
    "University of Pennsylvania",
    "University of Massachusetts Amherst",
    "The University of Texas at Austin",
    "University of Waterloo",
    "University of Michigan",
    "University of California, San Diego",
    "California Institute of Technology",
    "Cornell University",
    "Georgia Institute of Technology",
    "University of Illinois, Urbana-Champaign",
    "Princeton University",
    "University of California, Irvine"
]
Schools = Hash[School.all().map { |s| [s.handle, s] }];
PostParams = {
    "initial_search" => "true",
    "major_id" => "20",
    "graduation_date" => "2015-12-01",
    "cip_test" => "true",
    "school_id" => "88",
    "sid_date" => "fp2ccov4w30fa0jourbkwktj0925",
    "date" => "2015-09-25T07:00:00.0Z",
    "rows" => "500"
}

JobCategoryMapping = {
    "Accounting"=>["business", "data", "economics"],
    "Administration"=>["business", "data", "communications"],
    "Agent / Broker"=>["business", "humanities"],
    "Analysis"=>["business", "data"],
    "Customer Service"=>["business", "data", "communications"],
    "Design"=>["film_video_audioproduction", "communications"],
    "Education"=>["communications", "socialsciences"],
    "Engineering"=>["business", "mathematics", "otherengineering"],
    "Finance"=>["data", "business", "economics"],
    "Food Service"=>["data", "socialsciences"],
    "Health Care Provider"=>["health_medicine"],
    "Hospitality"=>["business", "data"],
    "Human Resources"=>["business"],
    "Information Services"=>["hardwareengineering", "softwareengineering"],
    "Law Enforcement"=>["communications"],
    "Maintenance"=>["data"],
    "Manufacturing"=>["communications"],
    "Marketing"=>["communications", "business"],
    "Nursing"=>["health_medicine"],
    "Occupational Therapy"=>["health_medicine"],
    "Other"=>["business"],
    "Pharmacy"=>["naturalsciences"],
    "Physical Therapy"=>["health_medicine"],
    "Research"=>["socialsciences", "otherengineering"],
    "Sales"=>["data", "communications", "business"],
    "Science"=>["socialsciences"],
    "Social Service"=>["socialsciences"],
    "Software Development"=>["hardwareengineering", "softwareengineering"],
    "Speech Language Pathology"=>["health_medicine"],
    "Supply Chain / Logistics"=>["business"],
    "Technician"=>["health_medicine"],
    "Transportation"=>["business", "data"],
    "Veterinary"=>["health_medicine"],
    "Writing / Editing"=>["communications", "languages", "journalism"]
}

Jobs = []
Companies = []
MutexLock = Mutex.new;


def sanitizeText(text)
  text.strip().gsub(/[\n|\t]+/, " ").gsub(/\s+/, ' ')
end

def GetCookieString(headers)
  return headers.to_h['set-cookie'].map{|cookie| cookie.split(';')[0]}.join('; ')
end

def GetBaseCookies
  response = HTTParty.get(SignInUrl)
  response.headers.to_h['set-cookie'].map{|cookie| cookie.split(';')[0]}.join('; ')
  unless response.blank?
    Headers["Cookie"] = GetCookieString(response.headers)
  end
  doc = Nokogiri::HTML(response.body)
  value = doc.at_xpath(".//form//input[@name='__RequestVerificationToken']").attr('value')
  return value
end

def SignIn()
  code = GetBaseCookies()
  # get the request verification code
  SignInForm['__RequestVerificationToken'] = code
  headers = Headers.clone()
  headers["Content-Length"] = "170"
  response =HTTParty.post(SignInUrl, :body => SignInForm, :headers => headers)
  unless response.headers["set-cookie"].blank?
    Headers["Cookie"] += ";#{GetCookieString(response.headers)}"
  end
end

def get_meta_params(school_name, major_id)
  url = URI(MetaParamsUrl)
  metaUrlParams = {
      "major_id" => major_id,
      "grad_month" => GraduationDate.month,
      "grad_year" => GraduationDate.year
  }
  unless school_name.blank?
    metaUrlParams["school_name"] = school_name
  end
  url.query = URI.encode_www_form( metaUrlParams )
  response = HTTParty.get(url.to_s);
  school_match = response.body.match(/var\siSchoolId\s=\s"(\d+)";/)
  sid_match = response.body.match(/var\ssid_date\s=\s("|')(.*)("|');/)
  if sid_match.blank?
      return nil
  end
  params = PostParams
  params["major_id"] = major_id
  unless school_match.blank?
    params["school_id"] = school_match[1]
  end
  params["sid_date"] = sid_match[2]
  params["date"] = (Time.now - 1.day).utc.iso8601.gsub("Z", ".0Z")
  params["graduation_date"] = GraduationDate.to_s
  return params
end

def load_major_mapping
  parsed_file = CSV.read(CollegeJobMajorMapping, { :col_sep => "\t" })
  majorMapping = parsed_file.map{|p| [p[3], p[0]]}.to_h
  return majorMapping
end

def get_jobs_for_school_meed_major(school_name, major_id, majorMapping)
  college_job_major_id = majorMapping[major_id]
  if college_job_major_id.blank?
    return
  end

  return get_jobs_for_school_major(school_name, college_job_major_id)
end

def get_jobs_for_school_major(school_name, college_job_major_id)
  params = get_meta_params(school_name, college_job_major_id)
  all_jobs = []
  (0..JobDayCount).each do |day|
    if day == 0
      params["initial_search"] = "true"
    else
      params["initial_search"] = "false"
    end
    params["date"] = (Time.now - day.day).utc.iso8601.gsub("Z", ".0Z")
    response = HTTParty.post(ExploreApiUrl, :body => params, :headers => Headers)
    if response.blank? || response.body.blank?
      next
    end
    begin
      jobs = JSON.parse(response.body)
    rescue
      next
    end
    if jobs["data"].blank?
      next
    end
    if jobs["data"]["jobs"].blank?
      next
    end
    all_jobs.concat(jobs["data"]["jobs"])
  end

  return all_jobs
end

def get_key_value_from_info_node(info_node)
  key = info_node.children()[1].inner_text
  value = info_node.children()[3].inner_text.strip()
  return [key, value]
end

def get_company_details(company_url, company_id)
  company_metadata = {}
  company_metadata["url"] = company_url
  company_metadata["company_id"] = company_id
  response = HTTParty.get(company_url)
  if response.blank?
      return nil
  end
  doc = Nokogiri::HTML(response.body)
  logo_node = doc.at_xpath("//div[@id='company-logo']//img")
  unless logo_node.blank?
    company_metadata['logo_url'] = logo_node.attr('src')
  end
  title_node = doc.at_xpath("//div[@id='company-description']//h1[@id='company-smb-name']")
  unless title_node.blank?
    company_metadata['name'] = title_node.inner_text
  end
  description_node = doc.at_xpath("//div[@id='company-description']//div[@id='company-desc-full']")
  unless description_node.blank?
    company_metadata['description'] = sanitizeText(description_node.inner_text)
  end
  return company_metadata
end

def get_external_url(job_id)
  begin
    apply_url = ApplyJobUrl % job_id
    apply_response = HTTParty.get(apply_url, :headers => Headers)
    if apply_response.blank?
      return nil
    end
    apply_doc = Nokogiri::HTML(apply_response.body);
    external_link_node = apply_doc.at_xpath(".//a[@id='ats_apply']")
    if external_link_node.blank?
      return nil
    end
    external_link = external_link_node.attr('href')
    if !external_link.include? "l.aftercollege.com"
      return external_link
    end
    # the link is a landing page link .. follow it to get the real url
    response = HTTParty.get(external_link)
    if response.blank?
      return nil
    end
    return response.request.last_uri.to_s
  rescue Exception
    return nil
  end

end

def get_job_details(job_data)
  job = job_data[0]
  schools = job_data[1]
  majors = job_data[2]
  job_metadata = {}
  job_url = JobDetailsUrl % job["job"]["companynumber"]
  job_metadata["id"] = job["job"]["companynumber"]
  job_metadata["url"] = job_url
  job_metadata["view_score"] = job["job"]["view_score"]
  job_metadata["score"] = job["score"]
  job_metadata["likes"] = job["likes"]
  job_metadata["schools"] = schools.to_a
  job_metadata["majors"] = majors.to_a
  response = HTTParty.get(job_url);
  if response.blank? || response.body.blank?
      return nil
  end
  doc = Nokogiri::HTML(response.body);
  job_info_nodes = doc.xpath("//div[@class='job_detail_sidepane_info']")
  job_metadata = job_metadata.merge(Hash[job_info_nodes.map{|info_node| get_key_value_from_info_node(info_node)}])
  job_title_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'jobtitle')]")
  unless job_title_node.blank?
    job_metadata["title"] = job_title_node.inner_text
  end
  job_company_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'job_detail_location')]/span[1]")
  unless job_company_node.blank?
      job_metadata['company_name'] = job_company_node.at_xpath(".//a").inner_text
      job_metadata['company_url'] = BaseUrl + job_company_node.at_xpath(".//a").attr('href')
      job_metadata['company_id'] = job_company_node.at_xpath(".//a").attr('href').gsub('/company/', '')
  end
  job_location_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'job_detail_location')]/span[2]")
  unless job_location_node.blank?
      job_metadata['location'] = job_location_node.inner_text.strip()
  end
  description_node = doc.at_xpath("//div[@id='jobdetail']/div[contains(@class, 'job_detail_description')]")
  unless description_node.blank?
      job_metadata['description'] = sanitizeText(description_node.inner_text)
  end
  job_metadata[:external_link] = get_external_url(job["job"]["companynumber"])
  return job_metadata
end

def get_update_jobs(jobs)
  # get job details
  STDERR.puts "Processing update jobs job with #{jobs.count()} jobs"
  job_details = jobs.map{|job| get_job_details(job)}
  MutexLock.synchronize {
    STDERR.puts "Jobs before = #{Jobs.count()}"
    Jobs.append(job_details)
    STDERR.puts "Jobs after = #{Jobs.count()}"
  }

end

def get_update_companies(urls)
  STDERR.puts "Processing update companies  with #{urls.count()} urls"
  company_details = urls.map{|url| get_company_details(url[0], url[1])}
  MutexLock.synchronize {
    STDERR.puts "Companies before = #{Companies.count()}"
    Companies.append(company_details)
    STDERR.puts "Companies after = #{Companies.count()}"
  }
end

def get_school_name(meed_school_name)
  url = SchoolSearchUrl %  URI.encode(meed_school_name)
  response = HTTParty.get(url)
  if response.blank?
    return nil
  end
  data = JSON.parse(response.body)
  if data.count() == 0
    return nil
  end
  return data[0]
end

def create_company(company_hash)
  company = Company.find(company_hash['company_id'])
  if !company.blank?
    return company
  end

  company = Company.new
  company.id = company_hash['company_id']
  company.company_id = company_hash['company_id']
  company.name = company_hash['name']
  company.description = company_hash['description']
  begin
    company.company_logo = convert_to_cloudinary(company_hash[:logo_url], 75, 75)
  rescue
  end
  meta_data = {'source': 'after-college', 'external_url': company_hash['url']}
  company.meta_data = meta_data
  company.save
  return company
end

def get_job_type(type_string)
  if type_string.blank?
    return nil
  end
  case type_string
    when 'Part time'
      return 'Part Time'
    when 'Intern/Co-op'
      return 'Internship'
    else
      return nil
  end
end

def get_major_types(job_category)
  if job_category.blank?
    return nil
  end
  if !JobCategoryMapping.has_key?(job_category)
    return nil
  end
  major_types = JobCategoryMapping[job_category]
  major_ids = MajorType.find(major_types).map{|type| type.major_ids}.flatten().uniq;
  return [major_types, major_ids]
end

def save_company_url(company)
  if company.blank? || company["logo_url"].blank? || (!company["logo_url"].include? "getlogo")
    return nil
  end
  db_company = Company.find(company["company_id"])
  if db_company.blank?
    return nil
  end

  # if company has logo skip
  if !db_company.company_logo.blank?
    return nil
  end

  # get cloudinary url
  cloudinary_url = convert_to_cloudinary(company["logo_url"], 100, 100)
  if cloudinary_url.blank?
    return nil
  end
  db_company.company_logo = cloudinary_url
  db_company.save
end

def create_job(job_hash)
  # check job based on extenal id
  job = Job.where(:'meta_data.source' => 'after-college', :'external_id' => job_hash["id"])
  if job.count() > 0
    return job[0]
  end

  job = Job.new()
  job.title = job_hash['title']
  job.description = job_hash['description']
  job.location = job_hash['location']
  job.company_id = job_hash['company_id']
  job.company = job_hash['company_name']
  job.create_dttm = Date.strptime(job_hash['Posted:'], "%m/%d/%Y")
  job.schools = Schools.keys()
  job.type = get_job_type(job_hash['Employment Type:'])
  majors = get_major_types(job_hash['Job Category:'])
  unless majors.blank?
    job.major_types = majors[0]
    job.majors = majors[1]
  end
  job.email = 'contact@getmeed.com'
  job.emails = ['contact@getmeed.com', 'vmk@getmeed.com']
  meta_info = {'source': 'after-college', 'external_id': job_hash['id'], 'external_url': job_hash['url']}
  job.meta_info = meta_info
  job.save
  return job
end

def get_job_from_url(job_url, majors = [])
  if job_url.blank?
    return
  end
  uri = URI.parse(job_url)
  if uri.blank?
    return
  end
  path = uri.path
  if path.blank?
    return
  end
  matches = /\/company\/(?<company-name>[^\/]+)\/(?<company-id>\d+)\/(?<job-id>\d+)\//.match(path)
  if matches.blank?
    return
  end
  job_id = matches['job-id']
  company_id = matches['company-id']
  if job_id.blank?
    return
  end

  job_metadata = {}

  job_url = JobDetailsUrl % job_id
  job_metadata["id"] = job_id
  job_metadata["url"] = job_url
  job_metadata["schools"] = ["all"]
  job_metadata["majors"] = majors

  response = HTTParty.get(job_url);
  if response.blank? || response.body.blank?
    return nil
  end
  doc = Nokogiri::HTML(response.body);
  job_info_nodes = doc.xpath("//div[@class='job_detail_sidepane_info']")
  job_metadata = job_metadata.merge(Hash[job_info_nodes.map{|info_node| get_key_value_from_info_node(info_node)}])
  job_title_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'jobtitle')]")
  unless job_title_node.blank?
    job_metadata["title"] = job_title_node.inner_text
  end
  job_company_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'job_detail_location')]/span[1]")
  unless job_company_node.blank?
    job_metadata['company_name'] = job_company_node.at_xpath(".//a").inner_text
    job_metadata['company_url'] = BaseUrl + job_company_node.at_xpath(".//a").attr('href')
    job_metadata['company_id'] = job_company_node.at_xpath(".//a").attr('href').gsub('/company/', '').chomp('/')
  end
  job_location_node = doc.at_xpath("//div[@id='job_detail_header']/div[contains(@class, 'job_detail_location')]/span[2]")
  unless job_location_node.blank?
    job_metadata['location'] = job_location_node.inner_text.strip()
  end
  description_node = doc.at_xpath("//div[@id='jobdetail']/div[contains(@class, 'job_detail_description')]")
  unless description_node.blank?
    job_metadata['description'] = sanitizeText(description_node.inner_text)
  end
  job_metadata[:external_link] = get_external_url(job_id)
  return job_metadata
end

# Main Program
majorMapping = load_major_mapping();
# sign in first
SignIn()
jobs_hash = {}
# for each school and major pair, get top 100 jobs.
SchoolsList.each do |school|
  STDERR.puts "Getting jobs for school: #{school}"
  school_name = get_school_name(school)
  if school_name.blank?
    STDERR.puts "coudn't find matching school name for school: #{school}"
    next
  end
  majorMapping.keys().each do |major_id|
    begin
      jobs = get_jobs_for_school_meed_major(school, major_id, majorMapping);
    rescue
      STDERR.puts "Unknown error for school: #{school}, major: #{major_id}"
      next
    end
    if jobs.blank?
      STDERR.puts "Jobs Empty for school: #{school}, major: #{major_id}"
      next
    end
    # creating a hash to have unique jobs
    jobs.each do |job|
      job_id = job["job"]["companynumber"]
      unless jobs_hash.has_key?(job_id)
        jobs_hash[job_id] = [job, Set.new(), Set.new()]
      end
      jobs_hash[job_id][1].add(school)
      jobs_hash[job_id][2].add(major_id)
    end
  end
end
STDERR.puts "Finished getting jobs for schools and majors"
STDERR.puts "Getting job details for: #{jobs_hash.count()}"

# get job details
pool = Thread.pool(ThreadPoolLimit);
jobs_per_thread = (jobs_hash.count() / ThreadPoolLimit).to_i
index = 0;
jobs_hash.values.each_slice(jobs_per_thread).each do |slice_jobs|
  pool.process{get_update_jobs(Array.new(slice_jobs))}
  index += 1
end
pool.shutdown

# doing this to help debugging
Jobs = Jobs.flatten()
STDERR.puts "Finishes Getting job details. Jobs: #{Jobs.count()}"

unique_urls = Jobs.map{|job| [job["company_url"], job["company_id"]]}.uniq

STDERR.puts "Getting Company information for: #{unique_urls.count()}"

# get unique list of companies
pool = Thread.pool(ThreadPoolLimit);
jobs_per_thread = (unique_urls.count() / ThreadPoolLimit).to_i
unique_urls.each_slice(jobs_per_thread).each do |urls|
  pool.process{get_update_companies(Array.new(urls))}
end
pool.shutdown
Companies = Companies.flatten()
STDERR.puts "Finishes Getting Company information. Companies: #{Companies.count()}"

File.open(JobsDump, "w") do |f|
  f.puts Jobs.to_json
end

File.open(CompaniesDump, "w") do |f|
  f.puts Companies.to_json
end


# Creating entries in db
Companies = Companies.select{|company| !company["name"].blank?}


