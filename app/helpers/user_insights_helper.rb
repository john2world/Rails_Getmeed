# Contains all the helper functions to get the required instrumentation data.
module UserInsightsHelper
  class InsightsForUser
    Date_count_map = %Q{
      function() {
        var date = this.event_start.getDate() + '-' + (this.event_start.getMonth()+1) + '-' + this.event_start.getFullYear()
        emit(date, 1);
      }
    }

    Date_count_reduce = %Q{
      function(key, values) {
        var result = 0;
        values.forEach(function(value) {
          result += value;
        });
      return result;
      }
    }
    def initialize(user_handle)
      if !user_handle.blank?
        @handle = user_handle
        @criteria_object = Instrumentation.where('event_payload.handle' => user_handle)
        @insights = UserInsights.where(:handle => user_handle).first_or_create
      end
    end

    def get_total_profile_view_count
      if @insights.blank? or @insights[:profile_views].blank?
        return 0
      else
        return @insights[:profile_views]['total_views']
      end
    end

    def get_profile_view_count_by_date
      if @insights.blank? or @insights[:profile_views].blank?
        return nil
      end
      return @insights[:profile_views]['date_views'].to_a
    end

    def get_profile_view_count_by_company
      if @insights.blank? or @insights[:profile_views].blank?
        return nil
      end
      return @insights[:profile_views]['company_views'].to_a
    end

    def get_resume_score_raw
      if (@insights.blank? || @insights[:resume_score].blank?)
        return 0
      else
        return @insights[:resume_score][:score]
      end
    end

    def get_resume_score
      profile  = Profile.where(:handle => @handle)
      if profile.blank?
        return 0
      end
      return profile.first[:score]
    end

    def get_resume_contributors
      if(@insights.blank? || @insights[:resume_score].blank?)
        return nil
      else
        return @insights[:resume_score]['contributions']
      end
    end
  end
end