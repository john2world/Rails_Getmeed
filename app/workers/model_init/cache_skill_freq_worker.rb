class CacheSkillFreqWorker
  include Sidekiq::Worker
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    skill_hist = load_model
    $redis.set("skill_hist", skill_hist)
    Futura::Application.config.skill_hist = skill_hist
    $redis.set('skill_hist_time', Time.now())
  end

  def load_model
    modelFileName = "skill_freq.model"
    skill_hist = {}
    file = File.new(Rails.root.join("config", "models", modelFileName), "r")
    totalCount = 0;
    while(line = file.gets)
      if (line.start_with?("#"))
        next
      end
      line = line.chomp
      cols = line.split("\t")
      if (cols.length == 2)
        # this is a feature weight
        skill_hist[cols[0]] = cols[1].to_i
        totalCount += cols[1].to_i;
      end
    end
    file.close

    # normalizing counts to probs
    skill_hist.each do |key, value|
      skill_hist[key] = value * 1.0/totalCount
    end
    return skill_hist
  end
end