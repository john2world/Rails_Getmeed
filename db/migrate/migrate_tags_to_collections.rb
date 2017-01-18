# get tags for all scrapes
ScrapeData.where(:tags => nil, :type => 'article').each do |scrape|
  # rescrape and repopulate the tags
  begin
    embedly_api =
        Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@resu.me)'
    obj = embedly_api.extract :url => scrape.url
  rescue
   next
  end

  if obj.blank?
    next
  end
  data = obj[0].marshal_dump

  if data.blank?
    next
  end

  if data[:keywords].blank?
    next
  end

  scrape.tags = data[:keywords].map{|tag| [tag["name"], tag["score"] * 1.0/100]}.sort_by{|v| -v[1]}
  scrape.save!
end

# migrate all UserGeneratedPosts first
UserGeneratedPosts.where(type: "story", poster_type: "user", :collections => nil).each do |post|
  post.collections = post.tags
  # get post tags from scrape
  scrape = ScrapeData.find(post.id)
  unless scrape.blank? || scrape.tags.blank?
    post.tags = scrape.tags
  end
  post.save!
end

# migrate feed items
FeedItems.where(type: "story", poster_type: "user", :collections => nil).each do |feed|
  feed.collections = feed.tags
  post = UserGeneratedPosts.find(feed.subject_id)
  unless post.blank? || post.tags.blank?
    feed.tags = post.tags
  end
  feed.save!
end
