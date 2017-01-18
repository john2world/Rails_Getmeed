# Takes input the names of the students in a tsv file
# Search in Gatech student directory the names of the students matching every word of name of the student
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

API_BASE_URL = 'https://www.directory.gatech.edu'
GATECH_DIRECTORY_SEARCH_URL = "/directory/results/%s/%s"

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

def map_fields(field, student)
  field_name = sanitize_text(field.at_xpath('./strong').inner_text);

  case field_name
    when 'E-MAIL:'
      text = field.at_xpath('./a').inner_text;
      student[:email] = text;
      student[:user_id] = text.split('@')[0];
    when 'DEPARTMENT:'
      text = sanitize_text(field.children()[1].inner_text);
      student[:major] = text;
    when 'TITLE:'
      text = sanitize_text(field.children()[1].inner_text);
      student[:title] = text;
  end
  return student
end

def student_by_result(result)
  detail_url = result.attributes['href'].value();
  name = result.inner_text;
  name_cols = name.split(',');
  name = name_cols[1].strip() + ' ' + name_cols[0].strip();
  uri = URI.join(API_BASE_URL, detail_url);
  response = makeHttpRequest(uri, Headers, nil, nil, QPS);
  student = {};
  student[:name] = name;
  unless response.body().blank?
    doc = Nokogiri::HTML(response.body());
    node = doc.at_xpath("//form[@id='gt-directory-directory-form']").parent();
    fields = node.xpath('./p');
    fields.each do |field|
      student = map_fields(field, student);
    end
  end
  return student;
end

def search_by_name(first_name, last_name)
  search_url = GATECH_DIRECTORY_SEARCH_URL % [first_name, last_name];
  uri = URI.join(API_BASE_URL, search_url);
  response = makeHttpRequest(uri, Headers, nil, nil, QPS);
  students = [];
  unless response.body().blank?
    doc = Nokogiri::HTML(response.body());
    node = doc.at_xpath("//form[@id='gt-directory-directory-form']").parent();
    results = node.xpath('./p/a');
    students = results.map{|result| student_by_result(result)}.compact();
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
  last_name = name_words.pop();
  students = []
  name_words.each do |word|
    students.concat(search_by_name(word, ''));
  end

  students.concat(search_by_name(',', last_name));

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