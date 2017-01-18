require 'rss'
OutputFileName = "/Users/ViswaMani/Desktop/florida_craiglist_gigs.tsv"
CraigsListBaseUrl = "http://gainesville.craigslist.org/search/cpg"
UrlParams = {
    :is_paid => 'yes',
    :nearbyArea => [637,372,256,570,128,343,238,467,125,639,353,80,376,257,638,333,640,39,562,203,237,205,20,331,635,557,186,37,332,427],
    :query => 'developer',
    :searchNearBy => 1,
    :s => 0
}

def get_craigslist_url(start_index)
  url_params = []
  UrlParams[:nearbyArea].each do |code|
    url_params.push("#{:nearbyArea}=#{code}");
  end
  url_params.push("is_paid=#{UrlParams[:is_paid]}");
  url_params.push("query=#{UrlParams[:query]}");
  url_params.push("searchNearBy=#{UrlParams[:searchNearBy]}");
  url_params.push("s=#{start_index}");

  # finally add format as rss
  url_params.push("format=rss");
  url = URI(CraigsListBaseUrl);
  url.query = url_params.join('&');
  return url
end

def fix_craiglist_url(url, code)
  if url.include? ".org/cpg"
    # the state code is missing so add it
    url = url.gsub(".org/cpg", ".org/#{code}/cpg");
  end
  return url
end

def get_email_from_item(feed_item, code)
  url = feed_item.link;
  url = fix_craiglist_url(url, code).gsub(".org/", ".org/reply/").gsub(".html", '');
  response = HTTParty.get(url);
  doc = Nokogiri::HTML(response.body);
  node = doc.at_xpath("//a[@class='mailapp']");
  if node.blank?
    return nil
  end
  sleep(2)
  return node.inner_text
end

def get_email_from_url(url)
  url = url.gsub(".org/", ".org/reply/").gsub(".html", '');
  response = HTTParty.get(url);
  doc = Nokogiri::HTML(response.body);
  node = doc.at_xpath("//a[@class='mailapp']");
  if node.blank?
    return nil
  end
  return node.inner_text
end

start_index = 0
last_count = 1
feed_items = []
while last_count > 0
  url = get_craigslist_url(start_index);
  sleep(2);
  response = HTTParty.get(url);
  last_count = 0;
  unless response.blank?
    begin
      feed = RSS::Parser.parse(response.body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''));
      feed_items.concat(feed.items);
      last_count = feed.items.count();
      start_index += last_count;
    rescue Exception => ex
    end
  end
end

feed_items_emails = feed_items.map{|item| [item, get_email_from_item(item, "jax")]};

# outputting to a file
File.open(OutputFileName, "w") do |f|
  feed_items_emails.each do |feed|
    f.puts "#{feed[0].title}\t#{feed[0].link}\t#{feed[1]}";
  end
end

missing_feed_items_emails.each do |feed|
  puts "#{feed[0].title}\t#{feed[0].link}\t#{feed[1]}";
end
