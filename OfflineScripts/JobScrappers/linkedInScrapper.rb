require 'uri'
require 'nokogiri'
require 'json'
require 'cgi/cookie'
require 'date'
require './OfflineScripts/JobScrappers/JobHelper.rb'
include JobHelper

################################################################################################################################
########################################################## Constants ###########################################################
################################################################################################################################

$headers = {
  "Proxy-Connection" => "keep-alive",
  "Cache-Control" => "max-age=0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
  "Accept-Language" => "en-US,en;q=0.8",
  "Cookie" => ""
}

ResultCountRegEx = /\<strong\>(?<result_count>[\d,]+)\<\/strong\> results/

LinkedInUserName = "vmk@resu.me"
LinkedInPassword = "ResumeLover"

LinkedInBaseurl = "https://www.linkedin.com/"

# Searching for Function=Engineering, Country=Us, Experience = EntryLevel & Internship
SearchParameters = {:countryCode => "us", :f_F => "eng", :f_E => "2,1"}
# coressponding Majors
Majors = ["eng_comp", "eng_electrical", "sci_comp"]

################################################################################################################################

################################################################################################################################
####################################################### Helper Functions #######################################################
################################################################################################################################

def getloginCookies
  url = URI.join(LinkedInBaseurl, "uas/login-submit")
  formParams = { 
    "isJsEnabled" => "false", 
    "source_app" => "", 
    "session_key" => LinkedInUserName, 
    "session_password" => LinkedInPassword, 
    "signin" => "Sign In", 
    "session_redirect" => "", 
    }
  response = makeHttpRequest(url, $headers, nil, formParams)
  
  abort("Error Getting Login Cookies") unless response != nil
  $headers["Cookie"] = response["Set-Cookie"]
  puts "Finished Getting Login Cookies"
end

def removeIrrelevantCookies
  # Some cookies are irrelevant and often make the search results wrong
  cookies = CGI::Cookie::parse($headers["Cookie"])
  $headers["Cookie"] = "li_at=#{cookies["li_at"][0]}; lang=\"v=2&lang=en-us\""
end

def mapExperience(experience)
  if experience == "Entry level"
    return "full_time_entry_level"
  elsif experience == "Internship"
    return "intern"
  else
    return nil
  end
end

def getJobDetails(job)
  url = URI.join(LinkedInBaseurl, "jobs2/view/#{job["id"]}")
  response = makeHttpRequest(url, nil, nil, nil)
  if response == nil
    return nil
  end
  #response = Net::HTTP.get_response(url)
  doc = Nokogiri::HTML(response.body())
  details = {}
  jobNode = doc.at_xpath("//div[@class='job-desc']")
  
  if jobNode == nil
    return nil
  end
  
  t = jobNode.at_xpath(".//div[@class='top-row']//div[@class='logo-container']//img")
  details[:company_image_url] = (t.nil?)? "" : t.attr("src").to_s
  t = jobNode.at_xpath(".//div[@class='top-row']//div[@class='content']//h1[@class='title']")
  details[:title] = (t.nil?)? "" : t.inner_text
  t = jobNode.at_xpath(".//div[@class='top-row']//div[@class='content']//h2[@class='sub-header']//span[@itemprop='name']")
  details[:company_name] = (t.nil?)? "" : t.inner_text
  t = jobNode.at_xpath(".//div[@class='top-row']//div[@class='content']//h2[@class='sub-header']/span[@itemprop='jobLocation']/span[@itemprop='description']")
  details[:location] = (t.nil?)? "" : t.inner_text
  t = jobNode.at_xpath(".//div[@class='details']//ul[@class='detail-list']/li")
  otherDetails = (t.nil?)? "" : Hash[jobNode.xpath(".//div[@class='details']//ul[@class='detail-list']/li").map{|detail| [detail.xpath(".//div[@class='label']").inner_text,detail.xpath(".//div[@class='value']").inner_text]}]
  if !otherDetails.nil?
    
    details[:duration] = otherDetails["Employment type"].to_s
    details[:job_id] = otherDetails["Job ID"].to_s
    details[:industry] = otherDetails["Industry"].to_s
    details[:experience] = otherDetails["Experience"].to_s
    details[:function] = otherDetails["Job function"].to_s
  end
  t = doc.at_xpath("//div[contains(@class, 'description-module')]/div[@class='content']")
  details[:description] = (t.nil?)? "" : t.inner_html
  details[:job_url] = url.to_s
  
  details[:company_id] = job["companyId"]
  details[:date] = job["fmt_postedDate"]
  puts "get job details for #{job["id"]}"
  return details
end

def jobSearch(limit=Float::INFINITY)
  getloginCookies()
  removeIrrelevantCookies()
  url = URI.join(LinkedInBaseurl, "vsearch/j")
  # initialization
  startCount = 0
  params = SearchParameters
  params[:page_num] = 1
  jobs = []
  begin
    puts "Searching for jobs page #{params[:page_num]}"
    response = makeHttpRequest(url, $headers, params, nil)
    
    doc = Nokogiri::HTML(response.body())
    # parsing voltron code
    voltron_code = JSON.parse(doc.xpath("//code[@id='voltron_srp_main-content']").inner_html.gsub("<!--","").gsub("-->",""))
    searchData = voltron_code["content"]["page"]["voltron_unified_search_json"]["search"]
    resultsCount = ResultCountRegEx.match(searchData["results_count_without_keywords_i18n"])[:result_count].gsub(",", "").to_i
  
    jobs = jobs.concat(searchData["results"].map{|job| getJobDetails(job["job"])})
    startCount += searchData["results"].count
    params[:page_num] += 1
  end while (startCount < resultsCount) and (startCount<=limit)
  return jobs
end

def convertToJobModel(job)
  job_hash = {}
  job_hash[:title] = job[:title]
  job_hash[:company] = job[:company_name]
  job_hash[:img_url] = job[:company_image_url]
  job_hash[:description] = job[:description]
  job_hash[:location] = job[:location]
  job_hash[:type] = mapExperience(job[:experience])
  job_hash[:culture_video_url] = nil
  job_hash[:job_url] = job[:job_url]
  job_hash[:post_date] = DateTime.parse(job[:date]).to_s
  job_hash[:id] = job[:job_id]
  job_hash[:source] = "LinkedIn"
  job_hash[:email] = "ssravi@live.com"
  return job_hash
end

################################################################################################################################

jobs = jobSearch().compact


if jobs.count == 0
  puts "Error Finishing job search"
  return
end

puts "Found total of #{jobs.count} jobs ..."
jobs = jobs.map{|job| convertToJobModel(job)}.compact;
# saving jobs
puts "Saving total of #{jobs.count} jobs ..."
jobs.each(){|job|
  result = save_job_extra(job, Majors)
  if result == nil || result == false
    puts "error saving job #{job}"
  end
}
#jobs.map{|job| save_job_extra(job, Majors)}