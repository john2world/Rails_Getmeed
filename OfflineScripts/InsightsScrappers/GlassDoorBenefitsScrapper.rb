# Get the Comapnies from the company DB
require './OfflineScripts/lib/utils.rb'
require 'json'
require 'thread/pool'
require 'HTMLEntities'
require 'nokogiri'
include Util

Headers = {
    "Proxy-Connection" => "keep-alive",
    "Cache-Control" => "max-age=0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
    "Accept-Language" => "en-US,en;q=0.8"
}

API_BASE_URL = 'http://www.glassdoor.com'
BENEFITS_API_PATH_URL_Format = "/Benefits/benefitsModuleAjax.htm?employerId=%s"
ThreadPoolLimit = 5
QPS = 4

def get_benefits(company_id)
  if company_id.blank?
    return
  end
  benefits_path = BENEFITS_API_PATH_URL_Format % [company_id]
  uri = URI.join(API_BASE_URL, benefits_path);
  response = makeHttpRequest(uri, Headers, nil, nil, QPS);

  response_json = JSON.parse(response.body());
  response_json["company_id"] = company_id;
  print response_json;
  print "\n";
end

pool = Thread.pool(ThreadPoolLimit);
filename = ARGV[0]
companies = []
File.readlines(filename).each do |line|
  line = line.chomp
  company_result = eval(line);
  companies = companies.push(company_result['id']);
end
$stderr.puts "finished reading file #{companies.count()}"

companies.each do |company_id|
  pool.process{get_benefits(company_id)}
end
# waiting for the pools to finish
pool.shutdown;