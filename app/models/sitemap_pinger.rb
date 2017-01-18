class SitemapPinger
  SEARCH_ENGINES = {
      google: 'http://www.google.com/webmasters/tools/ping?sitemap=%s',
      bing: 'http://www.bing.com/webmaster/ping.aspx?siteMap=%s'
  }

  def self.ping (ping_url)
    SitemapLogger.info Time.now
    SEARCH_ENGINES.each do |name, url|
      default_url = "http://#{ENV['hostname']}/sitemap.xml"
      unless ping_url.blank?
        default_url = ping_url
      end
      request = url % CGI.escape(default_url)
      SitemapLogger.info "  Pinging #{name} with #{request}"
      if Rails.env == 'production'
        response = Net::HTTP.get_response(URI.parse(request))
        SitemapLogger.info "    #{response.code}: #{response.message}"
        SitemapLogger.info "    Body: #{response.body}"
      end
    end
  end
end