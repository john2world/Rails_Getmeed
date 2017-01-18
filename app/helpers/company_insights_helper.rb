module CompanyInsightsHelper
  class InsightsForCompany
    GENERICMAJORS = ['Engineering']
    def initialize(school_id, company_id)
      if school_id.blank? || company_id.blank?
        return nil;
      end
      @company_hiring_insights = CompanyHiringInsights.where(school_id: school_id).where(company_id: company_id);
      @company_general_insight = CompanyInsights.where(company_id: company_id).first;
    end

    def hiring_stats_by_major_year
      hiring_stats = {}
      @company_hiring_insights.to_a.each do |hiring_stat|
        year = hiring_stat[:year]
        hiring_stat[:major_counts].each do |major_count|
          if major_count['major'].in? GENERICMAJORS
            next
          end
          if !hiring_stats.has_key?(major_count['major'])
            hiring_stats[major_count['major']] = {}
          end
          hiring_stats[major_count['major']][year] = major_count["count"];
        end
      end
      return hiring_stats;
    end

    def hiring_stats_by_major
      major_hiring_stats = {}
      @company_hiring_insights.to_a.each do |hiring_stat|
        hiring_stat[:major_counts].each do |major_count|
          key = major_count["major"];
          if key.in? GENERICMAJORS
            next;
          end
          if !major_hiring_stats.has_key?(key)
            major_hiring_stats[key] = 0;
          end
          major_hiring_stats[key] += major_count["count"];
        end
      end
      return major_hiring_stats;
    end

    def hiring_stats_by_skills
      skill_hiring_stats = {}
      @company_hiring_insights.to_a.each do |hiring_stat|
        hiring_stat[:skill_counts].each do |skill_count|
          key = skill_count['skill'];
          if !skill_hiring_stats.has_key?(key)
            skill_hiring_stats[key] = 0;
          end
          skill_hiring_stats[key] += skill_count['count'];
        end
      end
      return skill_hiring_stats
    end

    def interview_experience
      if @company_general_insight.blank?
        return nil
      end
      experience = {}
      if @company_general_insight[:interview].blank? || @company_general_insight[:interview]['experience'].blank?
        return nil
      end
      experience["Positive"] = @company_general_insight[:interview]['experience']['positive']
      experience["Negative"] = @company_general_insight[:interview]['experience']['negative']
      experience["Neutral"] = @company_general_insight[:interview]['experience']['neutral']
      return experience
    end

    def interview_difficulty
      if @company_general_insight.blank? || @company_general_insight[:interview].blank?
        return nil
      end
      return @company_general_insight[:interview]['difficulty'];
    end

    def hiring_sources
      if @company_general_insight.blank? || @company_general_insight[:interview].blank?
        return nil
      end
      return @company_general_insight[:interview]["source"]
    end

    def company_ratings
      if @company_general_insight.blank? || @company_general_insight[:ratings].blank?
        return
      end
      return @company_general_insight[:ratings];
    end

    def company_benefits_rating
      if @company_general_insight.blank? || @company_general_insight[:benefits].blank?
        return
      end
      return @company_general_insight[:benefits]["rating"];
    end

    def company_top_benefits
      if @company_general_insight.blank? || @company_general_insight[:benefits].blank?
        return
      end
      return @company_general_insight[:benefits]["top_benefits"];
    end

    def salaries_by_job
      if @company_general_insight.blank? || @company_general_insight[:salary].blank?
        return
      end
      salaries = @company_general_insight[:salary].map {|salary_insight|
        {job: salary_insight['job_title'],
         mean: salary_insight['mean'],
         min: salary_insight['min'],
         max: salary_insight['max']}};
      return salaries;
    end
  end
end