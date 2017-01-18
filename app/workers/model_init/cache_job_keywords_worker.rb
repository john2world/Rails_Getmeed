class CacheJobKeywordsWorker
  include Sidekiq::Worker
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    tags_idf = load_model
    $redis.set("job_tags_idf", tags_idf)
    Futura::Application.config.job_tags_idf = tags_idf
    $redis.set('job_tags_idf_time', Time.now())
  end

  def load_model
    modelFileName = "job_tag_idf.model"
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