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
SALARY_API_PATH_URL_Format = "/Salary/%s-Salaries-E%s.htm"
INTERN_SALARY_API_PATH_URL_Format = "/Intern-Salary/%s-Internship-Salary-E%s.htm"
ThreadPoolLimit = 5
QPS = 4

def get_detail_pay(job_data)
  # making search within US and for fresh grad
  final_url = '/GD'+job_data['job_url'].sub(',31.htm', ',24.htm')+'?filter.experienceLevel=LESS_THEN_ONE'
  uri = URI.join(API_BASE_URL, final_url);
  response = makeHttpRequest(uri, Headers, nil, nil)
  doc = Nokogiri::HTML(response.body())
  salary_table_node = doc.at_xpath("//table[@id='SalaryChart']")
  if (salary_table_node.blank?)
    # try without filter
    final_url = job_data['job_url'].sub(',31.htm', ',24.htm')
    uri = URI.join(API_BASE_URL, final_url)
    response = makeHttpRequest(uri, Headers, nil, nil)
    doc = Nokogiri::HTML(response.body());
    salary_table_node = doc.at_xpath("//table[@id='SalaryChart']");
  end
  if !salary_table_node.blank?
    nodes = salary_table_node.xpath(".//tr[@class='dataRow']");
    if !nodes.blank?
      salary_details = []
      nodes.each do |node|
        type_node = node.at_xpath(".//td[@class='occ']");
        mean_node = node.at_xpath(".//td[@class='mean']");
        min_node = node.at_xpath(".//td[@class='salaryGraph']//div[@class='lowValue']");
        max_node = node.at_xpath(".//td[@class='salaryGraph']//div[@class='highValue']");
        if (type_node.blank? || mean_node.blank? || min_node.blank? || max_node.blank?)
          next
        end
        matches = /([^\(]+)\s+\(([\d,]+)\)\s*/.match(type_node.inner_text)
        if (matches.blank? || matches.captures.count() != 2)
          next
        end
        salary_details.push({
                                'type' => matches.captures[0],
                                'count' => matches.captures[1],
                                'mean' => mean_node.inner_text,
                                'min' => min_node.inner_text,
                                'max' => max_node.inner_text
                            });
      end
      job_data['salary_details'] = salary_details;
    end
  end
  # use IO#print for better output format in threads.
  print job_data;
  print "\n";
end

def get_company_salary_data(company, job_type)
  if company[0].blank? || company[1].blank?
    return
  end
  if (job_type == "fulltime")
    salary_url = SALARY_API_PATH_URL_Format % [company[1], company[0]]
  else
    salary_url = INTERN_SALARY_API_PATH_URL_Format  % [company[1], company[0]]
  end

  uri = URI.join(API_BASE_URL, salary_url);
  response = makeHttpRequest(uri, Headers, nil, nil, QPS)
  doc = Nokogiri::HTML(response.body())
  salary_table_node = doc.at_xpath("//table[@id='SalaryChart']")
  if salary_table_node.blank?
    return
  end
  job_nodes = salary_table_node.xpath(".//tr[@class='dataRow']");
  if job_nodes.blank?
    return
  end
  # get only first page jobs as they are the most popular
  job_nodes.each do |job_node|
    title_node = job_node.at_xpath(".//td[@class='occ']//a");
    if title_node.blank?
      next
    end
    salary_count_node = job_node.at_xpath(".//td[@class='occ']//p[@class='rowCounts']/tt[@class='notranslate']");
    if salary_count_node.blank?
      next
    end
    mean_salary_node = job_node.at_xpath(".//td[@class='mean']");
    if mean_salary_node.blank?
      next
    end
    min_salary_node = job_node.at_xpath(".//td[@class='salaryGraph']//div[@class='lowValue']");
    if min_salary_node.blank?
      next
    end
    max_salary_node = job_node.at_xpath(".//td[@class='salaryGraph']//div[@class='highValue']");
    if max_salary_node.blank?
      next
    end
    # job data hash
    job_data = {}
    job_data['company_id'] = company[0];
    job_data['company_name'] = company[1];
    job_data['job_title'] = title_node.inner_text;
    job_data['job_url'] = title_node.attributes["href"].value;
    job_data['job_type'] = job_type;
    job_data['salary_count'] = salary_count_node.inner_text;
    job_data['mean_salary'] = mean_salary_node.inner_text;
    job_data['min_salary'] = min_salary_node.inner_text;
    job_data['max_salary'] = max_salary_node.inner_text;
    # check if the job is hourly
    if (job_data['job_url'].starts_with? "/Hourly-Pay")
      next
    end
    # get further details per job
    get_detail_pay(job_data);
  end
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
  $stderr.puts "getting salaries for #{company[1]}"
  pool.process{get_company_salary_data(company, 'fulltime')}
  # getting intern salaries
  pool.process{get_company_salary_data(company, 'intern')}
end
# waiting for the pools to finish
pool.shutdown;