class CacheProfileTagModelWorker
  include Sidekiq::Worker
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    profile_tags_idf = load_model
    $redis.set("profile_tags_idf", profile_tags_idf)
    Futura::Application.config.profile_tags_idf = profile_tags_idf
    $redis.set('profile_tags_idf_time', Time.now())
  end

  def load_model
    modelFileName = "profile_tag_idf.model"
    tags_idf = {}
    file = File.new(Rails.root.join("config", "models", modelFileName), "r")
    totalCount = 0;
    while(line = file.gets)
      if (line.start_with?("#"))
        next
      end
      line = line.chomp
      cols = line.split("\t")
      if (cols.length == 2)
        tags_idf[cols[0]] = cols[1].to_f
      end
    end
    file.close
    return tags_idf
  end
end