class CacheProfileScoreModelWorker
  include Sidekiq::Worker
  require 'ostruct'

  sidekiq_options retry: true, :queue => :default

  def perform
    profile_score_model = load_model
    $redis.set("profile_score_model", profile_score_model)
    Futura::Application.config.profile_score_model = profile_score_model
    $redis.set('profile_score_model_time', Time.now())
  end

  def load_model
    modelFileName = "profile_score.model"
    feature_weights = {}
    feature_parameters = {}
    file = File.new(Rails.root.join("config", "models", modelFileName), "r")
    while(line = file.gets)
      if (line.start_with?("#"))
        next
      end
      line = line.chomp
      cols = line.split("\t")
      if (cols.length == 2)
        # this is a feature weight
        feature_weights[cols[0]] = cols[1].to_f
      end
      if (cols.length == 4)
        # this is a feature parameter with mean and stdDev
        if(!feature_parameters.has_key?(cols[0]))
          feature_parameters[cols[0]] = {}
        end
        feature_parameters[cols[0]][cols[1]] = {:mean => cols[2].to_f, :stdDev => cols[3].to_f}
      end
    end
    file.close
    return {:parameters => feature_parameters, :weights => feature_weights}
  end

end