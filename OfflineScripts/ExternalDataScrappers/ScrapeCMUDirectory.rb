# Takes input the names of the students in a tsv file
# Search in CMU student directory the names of the students matching every word of name of the student
# in tsv file to have max matching students.
# Finally outputs the detailed data of the student and these can be duplicates.

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

API_BASE_URL = 'https://directory.andrew.cmu.edu'
CMU_DIRECTORY_SEARCH_URL = "/search/basic/results"
Request_Params = {
    'search[generic_search_terms]' => '',
    'commit' => 'Search'
}
ThreadPoolLimit = 5
QPS = 4

def read_users_from_file(filename)
  users = []
  fh = File.open(filename, 'r');
  fh.readlines().each do |line|
    cols = line.strip().split("\t");
    users.push(cols);
  end
  return users;
end

def sanitize_text(text)
  text = text.gsub(/[\t\n]/, '')
  text = text.gsub(/\s+/, ' ')
  text = text.strip()
end

def map_directory_section(section, student)
  if section.at_xpath('./span[@class="directory_field"]').blank?
    section_field_name = sanitize_text(section.inner_text);
  else
    section_field_name = sanitize_text(section.at_xpath('./span[@class="directory_field"]').inner_text);
    text = sanitize_text(section.children()[1].inner_text());
  end

  case section_field_name
    when 'Email:'
      student[:email] = text;
    when 'Andrew UserID:'
      student[:user_id] = text;
    when 'Advisor:'
      text = sanitize_text(section.children()[2].inner_text());
      student[:advisor] = text;
    when 'Department with which this person is affiliated:'
      text = sanitize_text(section.next().inner_text);
      student[:major] = text;
    when 'Student Class Level:'
      text = sanitize_text(section.next().inner_text);
      student[:degree] = text;
  end
  return student
end

def parse_single_result_node(node)
  student = {}
  student[:name] = sanitize_text(node.at_xpath('./h1').inner_text).gsub(' (Student)', '');
  dir_sections = node.xpath("./div[@class='directory_section']/div");
  dir_sections.each do |section|
    student = map_directory_section(section, student);
  end
  return student;
end

def parse_multiple_result_node(node)
  rows = node.xpath('./table/tr');
  students = []
  # first row is headers
  rows.drop(1).each do |row|
    cols = row.xpath('./td');
    student = {}
    last_name = sanitize_text(cols[0].at_xpath('./a').inner_text);
    first_name = sanitize_text(cols[1].at_xpath('./a').inner_text);
    user_id = sanitize_text(cols[2].at_xpath('./a').inner_text);
    is_student = sanitize_text(cols[3].inner_text) == 'Student';
    department = sanitize_text(cols[4].inner_text);
    student_url = cols[2].at_xpath('./a').attributes['href'].value();

    if (!is_student)
      next;
    end

    # getting further information from the url
    uri = URI.join(API_BASE_URL, student_url);
    response = makeHttpRequest(uri, Headers, nil, nil, QPS);
    if response.body().blank?
      student[:name] = first_name + ' ' + last_name;
      student[:user_id] = user_id;
      student[:major] = department;
    else
      doc = Nokogiri::HTML(response.body());
      node = doc.at_xpath("//div[@id='search_results']/div");
      student = parse_single_result_node(node);
    end
    students.push(student);
  end
  return students;
end

def search_by_word(word)
  search_params = Request_Params.clone();
  search_params['search[generic_search_terms]'] = word;
  uri = URI.join(API_BASE_URL, CMU_DIRECTORY_SEARCH_URL);
  response = makeHttpRequest(uri, Headers, nil, search_params, QPS);
  students = [];
  unless response.body().blank?
    doc = Nokogiri::HTML(response.body());
    node = doc.at_xpath("//div[@id='search_results']/div");
    if (!node.xpath('./table').blank?)
      # multiple results
      students.concat(parse_multiple_result_node(node));
    else
      # single result
      students.push(parse_single_result_node(node));
    end
  end
  return students;
end

def search_students(user)
  name = user[0].downcase()
  university_url = user[1]
  university_name = user[2]
  major = user[3]
  year = user[4]

  name_words = name.split(' ');
  students = []
  name_words.each do |word|
    students.concat(search_by_word(word));
  end

  students.each do |student|
    puts "#{student[:name]}\t#{student[:email]}\t#{student[:user_id]}\t#{student[:major]}\t#{student[:degree]}\t#{university_name}\t#{year}"
  end
end

users = []
ARGV.each do |filename|
  users.concat(read_users_from_file(filename));
end

pool = Thread.pool(ThreadPoolLimit);
# for each user get student(s)
users.each do |user|
  pool.process{search_students(user)}
end

pool.shutdown;