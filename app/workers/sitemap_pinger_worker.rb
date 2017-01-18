class SitemapPingerWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :low

  def perform(url)
    SitemapPinger.ping(url)
  end
end