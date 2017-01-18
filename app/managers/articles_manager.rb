module ArticlesManager
  include FeedItemsManager
  include CommonHelper
  include LinkHelper
  include ScrapeManager
  include PhotoManager
  $article_page_size = 5

  def get_today_blogs
    FeedItems.order_by([:_id, -1]).limit($article_page_size)
  end

  def update_article_views (id)
    Article.where(_id: id).inc(:view_count, 1)
  end

  def get_article(id)
    article = Article.find(id)
    if article.blank?
      scrape_data = get_scrape_by_id id
      article = scrape_and_create_article scrape_data
    end
    unless article.blank? or article.photo_id.blank?
      article[:photo] = get_photo(article.photo_id)
    end
    unless article.blank? or article.company_id.blank?
      article[:company] = get_company_by_id article.company_id
    end
    article
  end

end