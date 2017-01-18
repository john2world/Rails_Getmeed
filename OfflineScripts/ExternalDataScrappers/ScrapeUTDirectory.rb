# Takes input the names of the students in a tsv file
# Search in UW student directory the names of the students matching every word of name of the student
# in tsv file to have max matching students.
# Finally outputs the detailed data of the student and these can be duplicates.

require './OfflineScripts/lib/utils.rb'
require './OfflineScripts/lib/proxy.rb'
require 'json'
require 'thread/pool'
require 'HTMLEntities'
require 'nokogiri'
include Util
include Proxy

Headers = {
    "Proxy-Connection" => "keep-alive",
    "Cache-Control" => "max-age=0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
    "Accept-Language" => "en-US,en;q=0.8"
}

API_BASE_URL = 'http://www.utexas.edu/'
UT_DIRECTORY_SEARCH_URL = "/directory/advanced.php"
ThreadPoolLimit = 5
Request_Params = {
    'aq[Name]'=>'ashley',
    'aq[College/Department]'=>'School of Engineering',
    'aq[Title]'=>'',
    'aq[Email]'=>'',
    'aq[Home Phone]'=>'',
    'aq[Office Phone]'=>'',
    'scope'=>'all'
}
ThreadPoolLimit = 5
QPS = 4
Memoization = {}
def parse_node(node, proxy_host = nil, headers = nil)
  student = {}
  student_name = sanitize_text(node.text).downcase
  # save bandwidth by not querying users with same name again.
  if Memoization.has_key? student_name
    return
  else
    Memoization[student_name] = true
  end
  # proxy server
  url = node['href']
  uri = URI.parse(url)
  if uri.host.blank?
    uri = URI.join(proxy_host, url)
  end
  # coming from proxy server, the request is already proxied.
  response = Proxy.makeHttpRequest(uri, headers, nil, nil, QPS);
  unless response.body().blank?
    doc = Nokogiri::HTML(response.body());
    nodes = doc.xpath("//div[@id='moreinfo']/table/tr");
    nodes.each do |node|
      key_node = node.xpath(".//td")[0]
      value_node = node.xpath('.//td')[1]
      student[sanitize_text(key_node.text)] = sanitize_text(value_node.text);
    end
  end
  unless student.keys.count() == 0
    return student
  end
end

def search_by_word(word)
  search_params = Request_Params.clone();
  search_params['aq[Name]'] = word.downcase();
  uri = URI.join(API_BASE_URL, UT_DIRECTORY_SEARCH_URL);
  headers = Headers.clone()
  students = [];
  retry_count = 3
  while (students.count() ==0 && retry_count > 0)
    response, proxy_url = Proxy.makeHttpProxyRequest(uri, headers, search_params, nil, QPS);
    unless response.body().blank?
      doc = Nokogiri::HTML(response.body());
      nodes = doc.xpath("//div[@id='moreinfo']/a");
      if nodes.blank?
        # there might be a single result ... parse as single result
        student = {}
        nodes = doc.xpath("//div[@id='moreinfo']/table/tr");
        nodes.each do |node|
          key_node = node.xpath(".//td")[0]
          value_node = node.xpath('.//td')[1]
          student[sanitize_text(key_node.text)] = sanitize_text(value_node.text);
        end
        students += [student]
      else
        students = nodes.map{|node| parse_node(node, 'http://'+URI(proxy_url).host, headers)};
      end
    end
    retry_count -= 1
  end
  students.each do |student|
    if student.keys.count() == 0
      next
    end
    print_student(student)
  end
end

def print_student(student)
  puts "#{student['Name:']}\t#{student['Email:']}\t#{student['School/College:']}\t#{student['Major:']}\t#{student['Classification:']}\t#{student['Home Phone:']}\t#{student['Home Address:']}\n"
end

filename = ARGV[0];
unless filename.blank?
  # there is a file so parse names from the file
  fh = File.open(filename, 'r');
  fh.readlines().each do |line|
    cols = line.strip().split("\t");
    student_name = sanitize_text(cols[0]).downcase
    Memoization[student_name] = true
  end
end
final_students = []

first_names = User.where(:active => true).pluck(:first_name).map{|name| name.downcase.split(' ')}.flatten().uniq()
last_names = User.where(:active => true).pluck(:last_name).map{|name| name.downcase.split(' ')}.flatten().uniq()

pool = Thread.pool(ThreadPoolLimit);
# for each user get student(s)
first_names.each do |name|
  pool.process{search_by_word(name)}
end

last_names.each do |name|
  pool.process{search_by_word(name)}
end
pool.shutdown;