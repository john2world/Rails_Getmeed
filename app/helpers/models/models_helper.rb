# Helper module that runs models
# module contains functions for creating features and computing model scores
module Models
  module ModelsHelper
    include ProfileScoreHelper
  
    # computes the score for a profile
    def profile_score(profile)
      # creating features
      features = featurize(profile)
      # returning model score
      return run_model(features)
    end

    def profile_contributions(profile)
      features = featurize(profile)
      return run_model_feature_contributions(features)
    end

    def get_feature_contributions(profile)
      # creating features
      features = featurize(profile)
      return get_feature_contributions(features)
    end
  end
end