# Parses the HTML data from fb files that have the students list from college
# Usage: ScrapeFBCollegeStudents.rb <file1> <file2> <file3>
require 'nokogiri'

def sanitize_name(name)
  return name.gsub(/\([^\)]+\)/, '').strip();
end

def get_user_from_node(node)
  name_node = node.at_xpath(".//div[contains(@class, 'fwb')]");
  studies_node = node.at_xpath(".//div[contains(@class, '_52eh')]");

  name = sanitize_name(name_node.inner_text);
  major = studies_node.children()[0].inner_text;
  major = major.sub('Studies ', '').sub(' at ', '');
  school_url = studies_node.children()[1].attributes['href'].value();
  school_name = studies_node.children()[1].inner_text;

  return [name, school_url, school_name, major]
end

def get_users_from_file(filename)
  fh = File.open(filename, 'r');
  # get year from filename if possible
  year = File.basename(filename, '.*').split('_')[-1].to_i;
  doc = Nokogiri::HTML(fh.read());
  nodes = doc.xpath("//div[@id='browse_result_area']//div[@class='_4_yl']");
  users = nodes.map{|node| get_user_from_node(node).append(year)}
  return users
end

users = []
ARGV.each do |filename|
  users.concat(get_users_from_file(filename))
end

users.each do |user|
  user_string = user.join("\t");
  puts "#{user_string}";
end