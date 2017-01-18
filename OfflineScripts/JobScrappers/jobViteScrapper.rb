require 'thread/pool'
require 'uri'
require 'nokogiri'
require 'json'
require './OfflineScripts/JobScrappers/JobHelper.rb'
require 'HTMLEntities'
include JobHelper

################################################################################################################################
########################################################## Constants ###########################################################
################################################################################################################################

Headers = {
  "Proxy-Connection" => "keep-alive",
  "Cache-Control" => "max-age=0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
  "Accept-Language" => "en-US,en;q=0.8"
}
ResultCountPerQuery = 100
ThreadPoolLimit = 5

Uri = URI.join("http://search.jobvite.com", "/api/jobsearch");

Params = {:q => "engineering", :radius => 1000, :limit => ResultCountPerQuery, :start => 0}

# coressponding Majors
Majors = ["eng_comp", "eng_electrical", "sci_comp"]

################################################################################################################################

################################################################################################################################
####################################################### Helper Functions #######################################################
################################################################################################################################

def mapExperience(job_details)
  if (job_details[:category] != nil) && (job_details[:category].downcase.contains("intern"))
    return "intern"
  end
  
  if (job_details[:title] != nil) && (job_details[:title].downcase.contains("intern"))
    return "intern"
  end
  
  return "full_time_entry_level";
end

def getResultsCount
  uri = Uri.clone();
  params_local = Params.clone();
  params_local[:limit] = 1;
  uri.query = URI.encode_www_form(params_local)
  response = makeHttpRequest(uri, Headers, params_local, nil)
  results = JSON.parse(response.body)
  return results["totalResults"].to_i
end

# converts the job vite job into resume job model
def convertToJobModel(job_details)
  job_hash = {}
  job_hash[:title] = job_details["title"]
  job_hash[:company] = job_details["companyName"]
  job_hash[:img_url] = job_details["companyLogo"]
  job_hash[:description] = sanitizeDescription(job_details["jobdesc"])
  job_hash[:location] = job_details["location"]
  job_hash[:type] = get_job_type(job_hash[:title])
  job_hash[:culture_video_url] = job_details["video_url"]
  job_hash[:job_url] = job_details["url"].gsub(/\s+/,"")
  job_hash[:post_date] = DateTime.strptime(job_details["modified"],"%m/%d/%Y").to_s 
  job_hash[:id] = job_details["jobId"]
  job_hash[:source] = "JobVite"
  job_hash[:email] = "applications@resu.me"
  return job_hash
end

def getJobDetails(job)
  uri = URI.parse("http://search.jobvite.com/api/jobsearch?action=detail&jobId=#{job["jobId"]}")
  response = makeHttpRequest(uri, Headers, nil, nil)
  return JSON.parse(response.body)[0]
end

def get_save_job(result)
  job_details = getJobDetails(result);
  job_hash = convertToJobModel(job_details);
  
  puts "Saving job #{job_hash[:id]}"
  result = save_job_extra(job_hash, Majors)
  if result == nil || result == false
    puts "error saving job #{job_hash[:id]}"
  end
end

def get_jobs(count)
  uri = Uri.clone();
  params_local = Params.clone();
  params_local[:start] = count;
  uri.query = URI.encode_www_form(params_local)
  response = makeHttpRequest(uri, Headers, params_local, nil)
  if response == nil
    return
  end
  
  results = JSON.parse(response.body)
  
  # spanning threads to get job details and save them
  pool = Thread.pool(ThreadPoolLimit);
  
  puts "Got #{results["results"].count} jobs"
  results["results"].each{ |result|
    if !result["jobId"].blank?
      pool.process{get_save_job(result)};
    end
  }
  
  # waiting for threads to exit
  pool.shutdown;
  
end

################################################################################################################################

count = 0
resultCount = getResultsCount()
puts "Total Result Count is #{resultCount}"
pool = Thread.pool(ThreadPoolLimit);
begin
  puts "Starting thread with count = #{count}"
  pool.process{get_jobs(count)}
  count += ResultCountPerQuery
end while count < resultCount

# waiting for threads to exit
pool.shutdown;