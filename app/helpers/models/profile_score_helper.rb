# Helper module that runs profile score model
module Models
  module ProfileScoreHelper
    include UsersManager
    include UsersHelper
    include ProfilesManager
    include Distribution::Normal::Ruby_
    def featurize(profile)
      user = get_active_user_by_handle(profile[:handle]);
      if(user.nil? || user.blank?)
        return nil
      end
      internships = get_user_internships(nil, profile);
      courses = get_user_courses(nil, profile);
      edus = get_user_edus(nil, profile);
      works = get_user_works(nil, profile);
      pubs = get_user_publications(nil, profile);
      school = get_school_handle_from_email(user.id);
      return {
        handle: user[:handle],
        school: school,
        objective: (profile[:objective].nil? || profile[:objective].blank?)? 0 : 1,
        workExp_count: works.count,
        workExp_duration: works.map{|work| getWorkDurationMonths(work)}.sum,
        workExp_skillCount: works.map{|work| getSkills(work)}.flatten(1).uniq.length,
        internship_count: internships.count,
        internship_duration: internships.map{|work| getWorkDurationMonths(work)}.sum,
        internship_skillCount: internships.map{|work| getSkills(work)}.flatten(1).uniq.length,
        pub_count: pubs.count,
        courses_count: courses.count,
        edu_years: edus.map{|edu| getEducationYears(edu)}.sum,
        gpa: sanitizeGpa(user[:gpa])
      }
    end

    def get_transform_feature_values(model_parameters,features)
      transform_feature_values = {}
      transform_feature_values[:objective] = (model_parameters["objective"][:stdDev] == 0) ? 0 : normalTransform(features[:objective], model_parameters["objective"][:mean], model_parameters["objective"][:stdDev])
      transform_feature_values[:workExp_count] = (model_parameters["workExp_count"][:stdDev] == 0) ? 0 : normalTransform(features[:workExp_count], model_parameters["workExp_count"][:mean], model_parameters["workExp_count"][:stdDev])
      transform_feature_values[:workExp_duration] = (model_parameters["workExp_duration"][:stdDev] == 0) ? 0 : normalTransform(features[:workExp_duration], model_parameters["workExp_duration"][:mean], model_parameters["workExp_duration"][:stdDev])
      transform_feature_values[:workExp_skillCount] = (model_parameters["workExp_skillCount"][:stdDev] == 0) ? 0 : normalTransform(features[:workExp_skillCount], model_parameters["workExp_skillCount"][:mean], model_parameters["workExp_skillCount"][:stdDev])
      transform_feature_values[:internship_count] = (model_parameters["internship_count"][:stdDev] == 0) ? 0 : normalTransform(features[:internship_count], model_parameters["internship_count"][:mean], model_parameters["internship_count"][:stdDev])
      transform_feature_values[:internship_duration] = (model_parameters["internship_duration"][:stdDev] == 0) ? 0 : normalTransform(features[:internship_duration], model_parameters["internship_duration"][:mean], model_parameters["internship_duration"][:stdDev])
      transform_feature_values[:internship_skillCount] = (model_parameters["internship_skillCount"][:stdDev] == 0) ? 0 : normalTransform(features[:internship_skillCount], model_parameters["internship_skillCount"][:mean], model_parameters["internship_skillCount"][:stdDev])
      transform_feature_values[:pub_count] = (model_parameters["pub_count"][:stdDev] == 0) ? 0 : normalTransform(features[:pub_count], model_parameters["pub_count"][:mean], model_parameters["pub_count"][:stdDev])
      transform_feature_values[:courses_count] = (model_parameters["courses_count"][:stdDev] == 0) ? 0 : normalTransform(features[:courses_count], model_parameters["courses_count"][:mean], model_parameters["courses_count"][:stdDev])
      transform_feature_values[:edu_years] = (model_parameters["edu_years"][:stdDev] == 0) ? 0 : normalTransform(features[:edu_years], model_parameters["edu_years"][:mean], model_parameters["edu_years"][:stdDev])
      transform_feature_values[:gpa] = (model_parameters["gpa"][:stdDev] == 0) ? 0 : normalTransform(features[:gpa], model_parameters["gpa"][:mean], model_parameters["gpa"][:stdDev])
      return transform_feature_values
    end

    def run_model_feature_contributions(features)
      if features.blank?
        return 0
      end
      model_parameters = Rails.configuration.profile_score_model[:parameters][features[:school]]
      model_weights = Rails.configuration.profile_score_model[:weights]
      if model_parameters.nil? || model_parameters.blank?
        return 0
      end
      # applying normal transform to all features with coressponding mean and variance
      transform_feature_values = get_transform_feature_values(model_parameters, features)
      # final score is weighted summation of all features as all values are between 0 - 1
      contributions = {}
      contributions[:objective] = (model_weights["objective"] * transform_feature_values[:objective])
      contributions[:workExp] = (model_weights["workExp_count"] * transform_feature_values[:workExp_count]) +
                                (model_weights["workExp_duration"] * transform_feature_values[:workExp_duration]) +
                                (model_weights["workExp_skillCount"] * transform_feature_values[:workExp_skillCount])
      contributions[:internship] = (model_weights["internship_count"] * transform_feature_values[:internship_count]) +
                                   (model_weights["internship_duration"] * transform_feature_values[:internship_duration]) +
                                   (model_weights["internship_skillCount"] * transform_feature_values[:internship_skillCount])
      contributions[:publications] = (model_weights["pub_count"] * transform_feature_values[:pub_count])
      contributions[:courses] = (model_weights["courses_count"] * transform_feature_values[:courses_count])
      contributions[:education] = (model_weights["edu_years"] * transform_feature_values[:edu_years])
      contributions[:gpa] = (model_weights["gpa"] * transform_feature_values[:gpa])
      return contributions
    end
  
    def run_model(features)
      if (features.nil? || features.blank?)
        return 0
      end
      contributions = run_model_feature_contributions(features)
      score = contributions.values.sum()
      # rescaling score
      return (score*100).floor
    end
  
      private
      def getWorkDurationMonths(work)
        if(work.nil? || work[:start_year].blank? || work[:start_month].blank?)
          return 0
        end
        startTime = DateTime.parse("#{work[:start_month]} #{work[:start_year]}")
        if(work[:end_year].nil?)
          endTime = Time.zone.now
        else
          endTime = DateTime.parse("#{work[:end_month]} #{work[:end_year]}")
        end
      
        if(!startTime.nil? & !endTime.nil?)
          return ((endTime-startTime)/30).floor
        end  
      end
    
      def getSkills(work)
        if(work[:skills].nil?)
          return []
        end
        if work[:skills].kind_of?(Array)
          return work[:skills]
        else
          return work[:skills].split(',')
        end
      end 
    
      def getEducationYears(edu)
        if edu[:start_year].blank? || edu[:end_year].blank?
          return 0
        end
        startYear = edu[:start_year].to_i
        if(edu[:end_year].nil?)
          endYear = Time.zone.now.year
        else
          endYear = edu[:end_year].to_i
        end
        return endYear-startYear
      end
    
      def sanitizeGpa(gpa)
        if(gpa.nil? || gpa.blank?)
          return 0
        end
        matches = gpa.to_s.match(/\d+\.\d*/)
        if(matches.nil? || matches.length == 0)
          return 0
        else
          return matches[0].to_f
        end
      end
    
      def normalTransform(value, mean, stdDev)
        if value.blank?
          value = 0
        end

        if mean.blank?
          mean = 0
        end

        z = (value-mean) * 1.0/stdDev
        return Distribution::Normal::Ruby_.cdf(z)
      end      
  end
end