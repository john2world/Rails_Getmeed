# Reads the html content from the TiE Members html page and parses the content into a TSV
require 'nokogiri'
filename = ARGV[0];

def sanitize_text(text)
  text = text.gsub("\n", ' ').gsub("\t", ' ')
  text = text.gsub(/\s+/, ' ');
  text = text.strip();
  return text
end

doc = Nokogiri::HTML(File.read(filename));
nodes = doc.xpath("//div[@class='searchrow_block ']")
nodes.each do |node|
  name_node = node.at_xpath(".//div[@class='nick']")
  working_node = node.at_xpath(".//div[@class='age_from']")
  desc_node = node.at_xpath(".//div[@class='desc']")
  name = sanitize_text(name_node.inner_text);
  working = sanitize_text(working_node.inner_text);
  working = working.gsub('TiE SV', '');
  desc = sanitize_text(desc_node.inner_text);
  puts "#{name}\t#{working}\t#{desc}\n";
end



