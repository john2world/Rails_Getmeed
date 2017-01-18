include FeedItemsManager
include CommentsManager
include CollectionsManager

event = Event.new

event.id = 'ama-peddinti'
event.author_id = 'peddinti'
event.description = "Hi! My name is Mani, Co-Founder & CTO of Meed. Before founding Meed, I worked as a Software Engineer on the Shopping Ads Modeling team at Google for a year and a half. Before Google, I worked as a Data Scientist and Applied Researcher at Microsoft Bing. I have a ton of insight and advice I'd love to share with young professionals like yourself, so ask me anything! Fun fact: I graduated with a degree in Electrical Engineering, but now I work in Computer Science. Ask me how I made the transition!"
event.start_dttm = 44.hours.ago
event.end_dttm = 46.hours.ago
event.facebook_event_url = 'https://www.facebook.com/getonmeed/posts/1658961177680351'
event.collection_ids = [ASK_MEED_COLLECTION_ID]
event.followers = %w(nikitharaviraj claireyuan gjreddy)
event.major_type_ids = ['softwareengineering']
event.save

user = User.find('peddinti')
user.headline = 'Co-Founder & CTO - Meed, Former Googler & Microsoft'
user.save

feed_item = FeedItems.find('562e8833e2a07f3287000002')
comments = get_comments_for_feed(nil, '562e8833e2a07f3287000002')
comments.each do |comment|
  unless comment.poster_id.eql? 'vmk@getmeed.com'
    feed_item = FeedItems.new
    feed_item.collection_ids = event.collection_ids
    feed_item.title = comment.title
    feed_item.poster_id = comment.poster_id
    feed_item.type = 'story'
    feed_item.poster_type = 'user'
    feed_item.comment_count = 1
    feed_item.event_id = event.id
    feed_item.save
  end
end

feed_item.delete










