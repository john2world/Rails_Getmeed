require 'rss'
include ScrapeManager
include JobsManager

UpworkSection = 'Web, Mobile & Software Dev'
UpworkSubSection = 'Mobile Development'

UpWorkRssUrl = 'https://www.upwork.com/jobs/rss?cn1[]=%s&cn2[]=%s&t[]=0&t[]=1&dur[]=0&dur[]=1&dur[]=13&dur[]=26&dur[]=none&wl[]=10&wl[]=none&tba[]=0&exp[]=1&amount[]=Min&amount[]=Max&sortBy=s_tot_charge+desc&skip=%s'


def get_upwork_jobs(category, sub_category)
  skip = 0
  last_count = -1
  items = []
  while last_count != 0
    puts "Starting with skil count: #{skip}"
    url = UpWorkRssUrl % [CGI::escape(category), CGI::escape(sub_category), skip.to_s];
    response = HTTParty.get(url);
    retry_count = 0
    while (retry_count < 3) and response.blank?
      response = HTTParty.get(url)
      retry_count += 1
    end
    if response.blank?
      break
    end
    begin
      feed = RSS::Parser.parse(response.body.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''));
      items.concat(feed.items)
      last_count = feed.items.count()
      skip += last_count
    rescue
      break
    end
  end
  return items
end

items = get_upwork_jobs(UpworkSection, UpworkSubSection)
jobs = items.map{|item| get_scrape_data_from_upwork_url(item.link)}.select{|job| !job.blank?}
jobs.each do |job|
  puts "#{job['url']}"
  save_upwork_job(job, "softwareengineering")
end


