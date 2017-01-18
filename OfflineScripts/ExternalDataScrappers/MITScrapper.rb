require 'thread'
require 'thread/pool'

ThreadPoolLimit = 5

SearchUrl = 'http://web.mit.edu/bin/cgicso?options=lastnamesx&query=%s'
BaseUrl = 'http://web.mit.edu'

$allUsers = {}
AllUsers_Mutex = Mutex.new()

$allUserDetails = []
Headers = {
    "Accept"=>"application/json, text/javascript, */*; q=0.01",
    "Accept-Encoding"=>"gzip, deflate",
    "Accept-Language"=>"en-US,en;q=0.8",
    "Connection"=>"keep-alive",
    "Content-Type"=>"application/x-www-form-urlencoded",
    "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36",
    "X-Requested-With"=>"XMLHttpRequest",
}

def search_thread_wrapper(names)
  users = {}
  names.each do |name|
    users = users.merge(search(name))
  end
  AllUsers_Mutex.synchronize {
    $allUsers = $allUsers.merge(users)
  }
end

def search(name)
  url = SearchUrl % CGI::escape(name)
  response = HTTParty.get(url, :headers => Headers)
  if response.blank?
    return []
  end
  doc = Nokogiri::HTML(response.body);
  nodes = doc.xpath(".//td[@bgcolor = '#ffffff']//a")
  return Hash[nodes.map{|node| [node.attr("href"), {:name => node.inner_text, :url => node.attr("href")}]}]
end

def get_student_details_wrapper(nodes)
  users = []
  nodes.each do |node|
    sleep(0.5)
    users.append(get_student_details(node))
  end
  AllUsers_Mutex.synchronize {
    $allUserDetails.concat(users)
  }
end

def get_student_details(node)
  url = BaseUrl+node[:url]
  begin
    response = HTTParty.get(url, :headers => Headers)
  rescue
    return []
  end
  if response.blank?
    return []
  end
  doc = Nokogiri::HTML(response.body);
  retry_count = 0
  while retry_count < 3 and !(doc.xpath(".//td[@bgcolor = '#ffffff']").inner_text.include? "email: ")
    sleep((retry_count/2)+0.5)
    response = HTTParty.get(url, :headers => Headers)
    doc = Nokogiri::HTML(response.body);
    retry_count += 1
  end

  info = doc.xpath(".//td[@bgcolor = '#ffffff']")
  text = info.inner_text
  name_match = text.match(/\s+name:\s(.*)\n/)
  if !name_match.blank? and name_match.captures.count() > 0
    node[:name] = name_match[1].strip()
  end
  email_match = text.match(/\s+email:\s(.*)\n/)
  if !email_match.blank? and email_match.captures.count() > 0
    node[:email] = email_match[1].strip()
  end
  department_match = text.match(/\s+department:\s(.*)\n/)
  if !department_match.blank? and department_match.captures.count() > 0
    node[:department] = department_match[1].strip()
  end
  year_match = text.match(/\s+year:\s(.*)\n/)
  if !year_match.blank? and year_match.captures.count() > 0
    node[:year] = year_match[1].strip()
  end

  school_match = text.match(/\s+school:\s(.*)\n/)
  if !school_match.blank? and school_match.captures.count() > 0
    node[:school] = school_match[1].strip()
  end
  return node
end

last_names = User.where(:last_name.ne => nil).pluck(:last_name).map{|l| l.downcase}.uniq;
jobs_per_thread = (last_names.count() / ThreadPoolLimit).to_i
pool = Thread.pool(ThreadPoolLimit);
last_names.each_slice(jobs_per_thread).each do |names|
  pool.process{search_thread_wrapper(Array.new(names))}
end

pool.shutdown

jobs_per_thread = ($allUsers.values().count() / ThreadPoolLimit).to_i
pool = Thread.pool(ThreadPoolLimit);
$allUsers.values().each_slice(jobs_per_thread).each do |users|
  pool.process{get_student_details_wrapper(Array.new(users))}
end

pool.shutdown
$allUserDetails = $allUserDetails.compact
filename = './OfflineScripts/JobScrappers/mit_users.csv'
f = File.open(filename, 'w')
$allUserDetails.each do |user|
  if user.blank?
    next
  end
  year = 0
  unless user[:year].blank?
    year = user[:year].to_i
    year = 2016 - year
  end
  f.puts "#{'"'+user[:name]+'"'},#{user[:email]},#{user[:department]},#{user[:school]},#{year}"
end
f.close()


missing_users = $allUserDetails.select{|u| !u.blank?}.select{|u| u[:email].blank?};
$allUserDetails = $allUserDetails.select{|u| !u.blank?}.select{|u| !u[:email].blank?};
get_student_details_wrapper(missing_users)


