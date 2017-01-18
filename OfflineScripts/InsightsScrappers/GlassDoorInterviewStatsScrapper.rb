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
Interview_API_PATH_URL_Format = "/Interview/%s-Interview-Questions-E%s.htm"
ThreadPoolLimit = 5
QPS = 4

def get_interview_stats(company)
  # if company name as space replace with "-"
  company_name = company[1].gsub /[\,\.\(\) ]/, '-'
  company_name = company_name.gsub /\-+/, '-'
  company_name = company_name.chomp('-')
  interview_url = Interview_API_PATH_URL_Format % [company_name, company[0]];
  uri = URI.join(API_BASE_URL, interview_url);
  begin
    response = makeHttpRequest(uri, Headers, nil, nil, QPS);
  rescue Exception
    $stderr.puts "Error getting data for #{company[0]} #{company[1]}"
  end

  doc = Nokogiri::HTML(response.body())
  interview_stats_table_node = doc.at_xpath("//div[@id='AllStats']")
  experience_node = interview_stats_table_node.at_xpath(".//div[contains(@class,'experience')]//div[contains(@class, 'dataTbl')]");
  acquisition_node = interview_stats_table_node.at_xpath(".//div[contains(@class,'obtained')]//div[contains(@class, 'dataTbl')]");
  difficulty_node = interview_stats_table_node.at_xpath(".//div[contains(@class,'difficulty')]//div[contains(@class, 'dataTbl')]//div[contains(@class,'difficultyLabel')]");
  interview_experience = {}
  if (!experience_node.blank?)
    nodes = experience_node.xpath(".//div[@class='row']");
    nodes.each do |node|
      sub_nodes = node.xpath(".//div[contains(@class,'cell')]");
      if (sub_nodes.size() != 2)
        next
      end
      interview_experience[sub_nodes[0].inner_text.strip()] = sub_nodes[1].inner_text.strip();
    end
  end
  acquisition = {}
  if (!acquisition_node.blank?)
    nodes = acquisition_node.xpath(".//div[@class='row']");
    nodes.each do |node|
      sub_nodes = node.xpath(".//div[contains(@class,'cell')]");
      if (sub_nodes.size() != 2)
        next
      end
      acquisition[sub_nodes[0].inner_text.strip()] = sub_nodes[1].inner_text.strip();
    end
  end
  difficulty = ""
  if (!difficulty_node.blank?)
    difficulty = difficulty_node.inner_text.strip();
  end
  interview_stats = {}
  interview_stats["company_id"] = company[0];
  interview_stats["experience"] = interview_experience;
  interview_stats["acquisition"] = acquisition;
  interview_stats["difficulty"] = difficulty;
  print interview_stats;
  print "\n";
end

pool = Thread.pool(ThreadPoolLimit);
filename = ARGV[0]
companies = []
File.readlines(filename).each do |line|
  line = line.chomp
  company_result = eval(line);
  companies = companies.push([company_result['id'], company_result['name']]);
end
$stderr.puts "finished reading file #{companies.count()}"

companies.each do |company|
  $stderr.puts "getting interview stats for #{company[1]}"
  pool.process{get_interview_stats(company)}
end
# waiting for the pools to finish
pool.shutdown;

