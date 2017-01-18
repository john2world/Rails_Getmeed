#should go out once in every two weeks
namespace :text_clean_up_task do
  task clean_up: :environment do
    require "#{Rails.root}/app/helpers/common_helper.rb"
    include CommonHelper
    feed_items = FeedItems.all
    feed_items.each do |feed_item|
      unless feed_item[:description].blank?
        feed_item[:description] = process_text(feed_item[:description])
        feed_item.save!
      end
    end
  end

end