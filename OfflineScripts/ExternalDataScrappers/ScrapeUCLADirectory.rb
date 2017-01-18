# Takes input the names of the students in a tsv file
# Search in UCLA student directory the names of the students matching every word of name of the student
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

API_BASE_URL = 'http://www.directory.ucla.edu/'
DIRECTORY_SEARCH_URL = "/search.php"
Request_Params = {
    'group'=>'student',
    'cn'=>'',
    'mail'=>'',
    'url'=>'',
    'telephonenumber'=>'',
    'postaladdress'=>'',
    'postalcode'=>'',
    'admcode'=>'',
    'department'=>'',
    'title'=>'',
    'querytype'=>'person',
    'searchtype'=>'advanced'
}
ThreadPoolLimit = 5
QPS = 0.1

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

def parse_node(node)
  cols = node.xpath('./td');
  if cols.count() != 5
    return nil;
  end

  name = sanitize_text(cols[0].at_xpath('./span').inner_text);
  unless name.blank?
    name_cols = name.split(',');
    if name_cols.count() == 2
        name = (name_cols[1].strip() + ' ' + name_cols[0].strip()).titleize;
    end
  end


  unless cols[1].at_xpath('.//a').blank?
    email = URI.decode(cols[1].at_xpath('.//a').attributes['href'].value.gsub('mailto:', ''));
    user_id = email.split('@')[0];
  end

  phoneno = cols[2].inner_text;

  major = cols[3].inner_text;

  student = {}
  student[:name] = name;
  student[:email] = email;
  student[:user_id] = user_id;
  student[:major] = major;

  return student;
end

def search_by_word(word)
  search_params = Request_Params.clone();
  search_params['cn'] = word;
  uri = URI.join(API_BASE_URL, DIRECTORY_SEARCH_URL);
  response = makeHttpRequest(uri, Headers, nil, search_params, QPS);
  students = [];
  if !response.body().blank?
    doc = Nokogiri::HTML(response.body());
    nodes = doc.xpath("//table[contains(@class, 'results-normal')]/tr");
    # drop header
    students = nodes.drop(1).map{|node| parse_node(node)};
  else
    STDERR.puts "Invalid response for: #{uri}";
  end
  STDERR.puts "Users Count: #{students.size()}; uri: #{uri}; word: #{word}";
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

#pool = Thread.pool(ThreadPoolLimit);
# for each user get student(s)
# HACK
users.drop(37).each do |user|
  search_students(user)
  # disabling threading
  #pool.process{search_students(user)}
end

#pool.shutdown;