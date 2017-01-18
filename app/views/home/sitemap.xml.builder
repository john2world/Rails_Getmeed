base_url = "http://#{request.host_with_port}"
recruiter_url = "http://#{ENV['recruiter_hostname']}"
xml.instruct! :xml, :version => '1.0'

xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do

  xml.url do
    xml.loc "#{base_url}"
    xml.changefreq 'weekly'
    xml.priority 1.0
  end

  xml.url do
    xml.loc "#{recruiter_url}"
    xml.lastmod Time.now.to_date
    xml.changefreq 'weekly'
    xml.priority 0.9
  end

  xml.url do
    xml.loc "#{base_url}/contact"
    xml.lastmod Time.now.to_date
    xml.changefreq 'weekly'
    xml.priority 0.9
  end

  unless @users.blank?
    @users.each do |user|
      xml.url do
        xml.loc user.profile_url
        xml.priority 1.0
      end
    end
  end


  unless @companies.blank?
    @companies.each do |company|
      xml.url do
        xml.loc company.profile_url
        xml.priority 1.0
      end
    end
  end

  unless @articles.blank?
    @articles.each do |article|
      xml.url do
        xml.loc article.article_url
        xml.priority 1.0
      end
    end
  end

  unless @posts.blank?
    @posts.each do |feed|
      xml.url do
        xml.loc feed.url
        xml.priority 1.0
      end
    end
  end


end