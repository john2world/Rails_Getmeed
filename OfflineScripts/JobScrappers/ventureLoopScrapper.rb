require 'thread/pool'
require 'uri'
require 'nokogiri'
require './OfflineScripts/JobScrappers/JobHelper.rb'
require 'HTMLEntities'
include JobHelper

################################################################################################################################
########################################################## Constants ###########################################################
################################################################################################################################
# Constants and global variables
ResultCountRegExPattern = /Search\s+Results\s+:\s+(?<resultCount>\d+)\s+Job\s+found/
JobIdRegExPattern = /jobdetail\.php\?jobid=(?<jobid>\d+)/
CompanyIdRegExPattern = /companyprofile\.php\?cid=(?<cid>\d+)/
VCIdRegExPattern = /investorprofile\.php\?cid=(?<cid>\d+)/

Headers = {
  "Proxy-Connection" => "keep-alive",
  "Cache-Control" => "max-age=0",
  "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
  "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
  "Accept-Language" => "en-US,en;q=0.8"
}

SearchUri = URI.join("http://www.ventureloop.com", "/ventureloop/job_search_results.php")
DetailsUri = URI.join("http://www.ventureloop.com", "/ventureloop/jobdetail.php")
CompanyProfileUri = URI.join("http://www.ventureloop.com","/ventureloop/companyprofile.php")

Params = { :pageno => "0", :btn => "1", :jcat => "11", :dc => "all", :ldata => "%", :jt => "1", :jc => "1", :jd => "1", :d => "100"}

ThreadPoolLimit = 5

# Venture loop categories and majors 
# Cat 11 - BizDev; 12 - Eng Software; 13 - Eng Hardware; 15 - Eng QA.
Majors = {
  "11" => ["eng_comp", "sci_comp", "eng_electrical"],
  "12" => ["eng_comp", "sci_comp", "eng_electrical"],
  "13" => ["eng_electrical"],
  "15" => ["eng_comp", "sci_comp", "eng_electrical"]
}

MaxQps = 10

################################################################################################################################

################################################################################################################################
####################################################### Helper Functions #######################################################
################################################################################################################################

# converts venture loop duration to resume experience
def mapExperience(duration)
  if (duration != nil) && (duration.downcase == "full-time")
    return "full_time_entry_level"
  end
  
  if (duration != nil) && (duration.downcase.contains("intern"))
    return "intern"
  end
  
  return duration;
end

# parses job from html node
def parseJobNode(jobNode, headerColNos)
  cols = jobNode.xpath(".//td")
  date = cols[headerColNos[:date]];
  title = cols[headerColNos[:title]].xpath(".//a");
  company = cols[headerColNos[:company]].xpath(".//a");
  vc = cols[headerColNos[:vc]].xpath(".//a");
  location = cols[headerColNos[:location]];
  return {
    date: date.text,
    job_title: title.text,
    job_id: JobIdRegExPattern.match(title.attr("href"))[:jobid],
    company_name: company.text,
    company_id: CompanyIdRegExPattern.match(company.attr("href"))[:cid],
    vc_name: vc.map{|vci| vci.inner_text}.join(";"),
    vc_id: vc.map{|vci| VCIdRegExPattern.match(vci.attr("href"))[:cid]}.join(";"),
    location: location.text
  } 
end 

# converts the table header names to column index. This is so that even if the relative order of columns change, the code is robust.
def getHeaderColNos(headerNode)
  cols = headerNode.xpath("//th")
  colNames = []
  cols.each do |col|
    # converting to lower case and removing all white spaces
    colNames = colNames.push(col.text.downcase.gsub(/\s+/, ""))
  end
  return {
      date: colNames.index("date"), 
      title: colNames.index("jobtitle"), 
      company: colNames.index("company"), 
      vc: colNames.index("vc"), 
      location: colNames.index("location")}
end 

# converts the job vite job into resume job model
def convertToJobModel(job_details)
  job_hash = {}
  job_hash[:title] = job_details[:job_title]
  job_hash[:company] = job_details[:company_name]
  job_hash[:img_url] = job_details[:company_logo]
  job_hash[:description] = sanitizeDescription(job_details[:description])
  job_hash[:location] = job_details[:location]
  job_hash[:type] = get_job_type(job_hash[:title])
  job_hash[:culture_video_url] = nil
  job_hash[:job_url] = job_details[:url]
  job_hash[:post_date] = DateTime.strptime(job_details[:date],"%m-%d-%Y").to_s
  job_hash[:id] = job_details[:job_id]
  job_hash[:source] = "VentureLoop"
  job_hash[:email] = "applications@resu.me"
  #puts job_hash;
  return job_hash
end

# Fetches company logo url based on company id
def get_company_logoUrl(cid)
  uri = CompanyProfileUri.clone();
  params_local = {:cid => cid}
  response = makeHttpRequest(uri, Headers, params_local, nil, MaxQps, "ventureloop_maintenance.php")
  doc = Nokogiri::HTML(response.body)
  
  logo_url = doc.at_xpath("//div[@id='formContainer']//div/img")
  if(logo_url == nil)
    return
  end
  
  return logo_url.attr("src");
  
end

# Thead runnable method to get job details and then save the job
def get_job_Details_save(job, cat)
  uri = DetailsUri.clone();
  params_local = {:jobid => job[:job_id]}
  
  response = makeHttpRequest(uri, Headers, params_local, nil, MaxQps, "ventureloop_maintenance.php")
  
  doc = Nokogiri::HTML(response.body)
  
  detailsNodes = doc.xpath("//div[@id='jobDetailPage']/div[@id='formContainer']/form/div[@id='formContainer'][1]/div[@class='form-line']")
  details = {}
  detailsNodes.each() do |node|
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "job title:"
      details[:job_id] = job[:job_id]
      details[:job_title] = node.xpath(".//div[@class='titleElement']").first.inner_text.strip
      next
    end
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "job date:"
      details[:date] = node.xpath(".//div[@class='titleElement']").first.inner_text.strip
      next
    end
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "duration:"
      details[:duration] = node.xpath(".//div[@class='titleElement']").first.inner_text.strip
      next
    end
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "company:"
      details[:company_id] = job[:company_id]
      details[:company_name] = node.xpath(".//div[@class='titleElement']").first.inner_text.strip
      next
    end
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "job location(s):"
      details[:location] = node.xpath(".//div[@class='titleElement']").first.inner_html.gsub(/\s+/, " ").sub("<br>", ";").strip.chomp(';')
      next
    end
    if node.xpath(".//div[@class='shortBubble' or @class='largeBubble']").first.inner_text.to_s.downcase == "description:"
      details[:description] = node.xpath(".//div[@class='titleElement']").first.inner_html.to_s
      next
    end
  end  
  details[:vc_name] = job[:vc_name]
  details[:vc_id] = job[:vc_id]
  details[:url] = uri.to_s;
  details[:company_logo] = get_company_logoUrl(job[:company_id]);
  
  jobModel = convertToJobModel(details);
  
  puts "Saving job #{jobModel[:id]}"
  result = save_job_extra(jobModel, Majors[cat])
  if result == nil || result == false
    puts "error saving job #{jobModel[:id]}"
  end
end

# thread callable method to get jobs for a given category and page no
def get_jobs(cat,pageNo)
  puts "Getting jobs for Cat: #{cat} and pageNo #{pageNo}"
  params_local = Params.clone()
  params_local[:pageno] = pageNo
  params_local[:jcat] = cat
  uri = SearchUri.clone()
  response = makeHttpRequest(uri, Headers, params_local, nil, MaxQps, "ventureloop_maintenance.php")
  doc = Nokogiri::HTML(response.body)
  resultsCount = ResultCountRegExPattern.match(doc.xpath("//div[@id='formContainer']//div[@class='formLs']").first.inner_text.to_s)[:resultCount].to_i
  puts resultsCount
  jobs = doc.xpath("//div[@id='formContainer']//table/tr");
  headerColNos =  getHeaderColNos(jobs[0]);
  # dropping the first row, which contains the header.
  jobs = jobs.drop(1).map{|job| parseJobNode(job, headerColNos)}
  # parsing html nodes to get job objects and then saving them
  puts "Processing #{jobs.count} jobs"
  pool = Thread.pool(ThreadPoolLimit);
  jobs.each{|job|
    pool.process{get_job_Details_save(job,cat)};
  }
  
  # waiting for threads to exit
  pool.shutdown;
end

# fetches the result count for a given category
def get_resultsCount(cat)
  params_local = Params.clone()
  params_local[:pageno] = 1
  params_local[:jcat] = cat
  uri = SearchUri.clone()
  response = makeHttpRequest(uri, Headers, params_local, nil, MaxQps, "ventureloop_maintenance.php")
  doc = Nokogiri::HTML(response.body)
  resultsCount = ResultCountRegExPattern.match(doc.xpath("//div[@id='formContainer']//div[@class='formLs']").first.inner_text.to_s)[:resultCount].to_i
  return resultsCount
end

# Thread callable method to get all jobs for a given category
def get_jobsPerCategory(cat)
  # getting the result count for the coressponding category
  resultsCount = get_resultsCount(cat);
  puts "ResultCount: #{resultsCount}";
  pool = Thread.pool(ThreadPoolLimit);
  # generating page_nos
  page_nos = (1..(resultsCount%25)+1).to_a;
  page_nos.each{ |page_no|
    puts "Starting thread with #{cat} #{page_no}"
    pool.process{get_jobs(cat,page_no)};
  }
  pool.shutdown;  
end

################################################################################################################################

################################################################################################################################
######################################################### Main Program #########################################################
################################################################################################################################

# getting jobs for each category
pool = Thread.pool(ThreadPoolLimit);
Majors.keys().each{|cat|
  pool.process{get_jobsPerCategory(cat);}
}

# waiting for the pools to finish
pool.shutdown;