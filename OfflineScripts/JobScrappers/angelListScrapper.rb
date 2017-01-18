require 'net/http'
require 'thread/pool'
require 'uri'
require 'nokogiri'
require 'chronic_duration'
require 'digest/sha1'
require './OfflineScripts/JobScrappers/JobHelper.rb'
include JobHelper
include ChronicDuration

################################################################################################################################
########################################################## Constants ###########################################################
################################################################################################################################
# limiting only to software 
SearchParameters = "{\"types\":[\"full-time\",\"internship\"],\"roles\":[\"Software Engineer\"]}";
# coressponding Majors
Majors = ["eng_comp", "eng_electrical", "sci_comp"]

SearchUrl = "https://angel.co/jobs#find/f!"
CompanyUrl = "https://angel.co"
StartupTableUrl = "https://angel.co/job_listings/browse_startups_table?"

$headers = {
  "Proxy-Connection" => "keep-alive",
  "Cache-Control" => "max-age=0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
  "Accept-Language" => "en-US,en;q=0.8"
}

ThreadPoolLimit = 5
StartupCompaniesPerUrl = 50
MaxQps = 10

################################################################################################################################

################################################################################################################################
####################################################### Helper Functions #######################################################
################################################################################################################################

# Getting the profile of a company like video url, description etc.
def getCompanyProfile(company)
  uri = URI.join(CompanyUrl, company[:company].gsub(" ", "-").downcase)
  response = makeHttpRequest(uri, $headers, nil, nil, MaxQps)
  if response == nil
    puts "Error Getting profile for company #{company}"
    return nil
  end
  doc = Nokogiri::HTML(response.body)
  
  details = {}
  videoNode = doc.at_xpath("//div[contains(@class, 'screenshots_and_video')]//iframe")
  if videoNode != nil
    details[:video_url] = videoNode.attr("src")
  end
  
  details[:description] = ""
  
  descriptionNode = doc.at_xpath("//div[contains(@class, 'product_desc')]")
  if descriptionNode != nil
    details[:description] = descriptionNode.inner_html
  end
  
  return details
    
end

# Getting jobs from the company page
def getJobs(company)
  puts "Fetching jobs for company #{company[:id]}"
  uri = URI.join("https://angel.co","/job_listings/browse_startup_details")
  params = { :startup_id => company[:id] }
  
  response = makeHttpRequest(uri, $headers, params, nil, MaxQps)
  if response == nil
    puts "Error Getting jobs for company #{company}"
    return nil
  end
  doc = Nokogiri::HTML(response.body)
  node = doc.xpath("//div[contains(@class, 'details-row') and contains(@class, 'product')]")
  if(node == nil)
    puts "Error Getting jobs for company #{company}"
    return nil
  end
  
  company_profile = getCompanyProfile(company)
  
  $description = ""
  $description += doc.xpath("//div[contains(@class, 'details-row') and contains(@class, 'product')]").inner_html.to_s
  $description += "<br>"
  $description += "<div>For more information about #{company[:company]} visit <a href=\"#{company[:company_url]}\">#{company[:company_url]}</a>.</div>"
  jobNodes = doc.xpath("//div[contains(@class, 'details-row') and contains(@class, 'jobs')]/div[@class='content']/div[@class='listing-row']")
  
  company_profile[:description] = sanitizeDescription($description)
  active = doc.xpath("//div[@class='active']").inner_text.strip
  
  active_time = (Time.zone.now().to_time - ChronicDuration.parse(active).seconds).to_s
  
  if(jobNodes == nil)
    puts "Error Getting jobs for company #{company}"
    return nil
  end
  jobs = []
  jobNodes.each do |jobNode|
    title = jobNode.xpath(".//div[@class='top']/div[@class='title']").inner_text
    tags = jobNode.xpath(".//div[@class='tags']").inner_text.split("\u00B7")
    record = {:job_title => title, :duration => (tags[0].nil?)? "" : tags[0].strip, :location => (tags[1].nil?)? "" : tags[1].strip, :area => (tags[2].nil?)? "" : tags[2].strip, :tags => (tags[3].nil?)? "" : tags.drop(3).join(",").strip}
    record[:job_url] = uri
    record[:description] = company_profile[:description]
    record[:active_time] = active_time
    record[:company] = company[:company]
    record[:company_logo] = company[:image_url]
    record[:job_url] = company[:company_url]
    # since there is no job id, creating job id by appending company id with hash of job title
    record[:id] = company[:id]+"_"+Digest::SHA1.hexdigest(title)
    record[:video_url] = company_profile[:video_url]
    jobs.push(record)
  end
  return jobs
end

# parses a startup html node
def parseStartupInfo(startupNode)
  id = startupNode.attr("data-startup_id").to_s
  name = startupNode.attr("data-startup_name").to_s
  image_url = startupNode.xpath(".//div[@class='pic']/a/img").attr("src").to_s
  company_url = startupNode.xpath(".//div[@class='pic']/a").attr("href").to_s
  return {:id => id, :company => name, :image_url => image_url, :company_url => company_url}
end

# converts the angellist experience information to resume format
def mapExperience(experience)
  if experience == "Full Time"
    return "full_time_entry_level"
  elsif experience == "Internship"
    return "intern"
  elsif experience == "Contract"
    return "contract"
  else
    return nil
  end
end

# converts the angel list job into resume job model
def convertToJobModel(job)
  job_hash = {}
  job_hash[:title] = job[:job_title]
  job_hash[:company] = job[:company]
  job_hash[:img_url] = job[:company_logo]
  job_hash[:description] = job[:description]
  job_hash[:location] = job[:location]
  job_hash[:type] = get_job_type(job_hash[:title])
  job_hash[:culture_video_url] = job[:video_url]
  job_hash[:job_url] = job[:job_url]
  job_hash[:post_date] = job[:active_time]
  job_hash[:id] = job[:id]
  job_hash[:source] = "AngelList"
  job_hash[:email] = "applications@resu.me"
  job_hash[:job_url] = job[:job_url]
  return job_hash
end

# Thread callable function to fetch and save jobs for a company
def get_save_jobs(company)
  # getting jobs for the company
  jobs = getJobs(company)
  puts "Found #{jobs.count} jobs for company: #{company[:company]} (#{company[:id]})"
  # converting jobs to job model
  jobs = jobs.map{|job| convertToJobModel(job)}
  #saving jobs to resume DB
  puts "Saving #{jobs.count} to db"
  jobs.each(){|job|
    puts "saving job #{job}"
    result = save_job_extra(job, Majors)
    if result == nil || result == false
      puts "error saving job #{job}"
    end
  }
end

# Thread callable high level function to get companies and then get_save_jobs
def get_company_jobs(startupIds)
  augmentation = startupIds.map{|id| "startup_ids%5B%5D=#{id}"}.join("&")
  uri = URI.parse(StartupTableUrl+augmentation)
  response = makeHttpRequest(uri, $headers, nil, nil, MaxQps)
  if response == nil
    return
  end
  doc = Nokogiri::HTML(response.body)
  node = doc.xpath("//div[contains(@class, 'startup-row')]")
  if node == nil
    return
  end
  startupCompanies = node.map{|startupNode| parseStartupInfo(startupNode)};
  
  # spanning threads to get and save jobs
  pool = Thread.pool(ThreadPoolLimit)
  startupCompanies.each{|company| pool.process {get_save_jobs(company)}};
  
  #waiting for pools to exit
  pool.shutdown
end

################################################################################################################################

################################################################################################################################
######################################################### Main Program #########################################################
################################################################################################################################

uri = URI.parse(SearchUrl + URI.escape(SearchParameters))
response = makeHttpRequest(uri, $headers, nil, nil, MaxQps)

abort("Error Getting startup companies") unless response != nil
doc = Nokogiri::HTML(response.body)
node = doc.xpath("//div[contains(@class, 'startup-container')]")

abort("Error Getting startup companies") unless node != nil
startupIds = node.attr("data-startup_ids").to_s.sub("[","").sub("]","").split(",")

puts "Finished Fetching #{startupIds.count} Startup Company ids ..."

# Get the startup information from startup ids
$startCount = 0
startupCompanies = []
# Starting thread pool for companies
pool = Thread.pool(ThreadPoolLimit);

while ($startCount < startupIds.count) do 
  puts "Fetching next #{StartupCompaniesPerUrl} Startup Company details"
  
  pool.process{get_company_jobs(startupIds.drop($startCount).take(StartupCompaniesPerUrl))}
  $startCount += StartupCompaniesPerUrl
  #$stderr.puts $startCount
end

# waiting for threads to exit
pool.shutdown


