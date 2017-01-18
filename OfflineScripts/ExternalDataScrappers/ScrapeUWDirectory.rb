# Takes input the names of the students in a tsv file
# Search in UW student directory the names of the students matching every word of name of the student
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

API_BASE_URL = 'http://www.washington.edu/'
CMU_DIRECTORY_SEARCH_URL = "/home/peopledir/"
Request_Params = {
    'term' => '',
    'method' => 'name',
    'whichdir' => 'student',
    'length' => 'full'
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
  if text.blank?
    return
  end
  text = text.gsub(/[\t\n]/, '')
  text = text.gsub(/\s+/, ' ')
  text = text.strip()
end

def parse_node(node)
  student = {}
  current = node;
  # previous element would be dummy text
  current = current.previous();

  if current.previous().name == 'br' && current.previous().previous().name == 'text' && current.previous().previous().previous().name == 'ul'
    # the email and multi address are present
    current = current.previous().previous();
    email = current.inner_text;
    unless email.blank?
      user_id = email.split('@')[0];
    end

    current = current.previous();
    multi_addr_node = current;
    major_string = multi_addr_node.xpath(".//li")[0].inner_text;
    major = sanitize_text(major_string.split(",")[1]);
    degree = sanitize_text(major_string.split(",")[0]);
  elsif current.previous().name == 'br' && current.previous().previous().name == 'text' && current.previous().previous().previous().name != 'form'
    # email node present and multi address not present
    current = current.previous().previous();
    email = current.inner_text;
    unless email.blank?
      user_id = email.split('@')[0];
    end
  elsif current.previous().name == 'br' && current.previous().previous().name == 'ul'
    # email not present multi address present
    current = current.previous().previous();
    multi_addr_node = current;
    major_string = multi_addr_node.xpath(".//li")[0].inner_text;
    major = sanitize_text(major_string.split(",")[1]);
    degree = sanitize_text(major_string.split(",")[0]);
  end

  # name node sould always be present
  if current.previous().previous().name != 'text'
    return nil
  end
  name_node = current.previous().previous();
  name_string = sanitize_text(name_node.inner_text);
  name = sanitize_text(name_string.split(';')[0]);
  phone_no = sanitize_text(name_string.split(';')[1]);

  student[:name] = name;
  student[:major] = major;
  student[:user_id] = user_id;
  student[:email] = email;
  student[:degree] = degree;
  student[:phone_no] = phone_no;
  return student;
end

def search_by_word(word)
  search_params = Request_Params.clone();
  search_params['term'] = word;
  uri = URI.join(API_BASE_URL, CMU_DIRECTORY_SEARCH_URL);
  response = makeHttpRequest(uri, Headers, nil, search_params, QPS);
  students = [];
  unless response.body().blank?
    doc = Nokogiri::HTML(response.body());
    nodes = doc.xpath("//form[@class='vcard']");
    students = nodes.map{|node| parse_node(node)};
  end
  return students;
end

def search_students(user)
  name = user[0].downcase();
  university_url = user[1];
  university_name = user[2];
  major = user[3];
  year = user[4];

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