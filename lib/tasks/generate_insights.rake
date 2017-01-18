namespace :generate_insights do
    task update_profile_view_counts: :environment do
      require "#{Rails.root}/app/helpers/jobs_helper.rb"
      include JobsHelper
      User.where(:active => true).to_a.each do |user|
        if user[:handle].blank?
          next
        end
        user_insight = UserInsights.where(:handle => user[:handle]).first_or_create
        if user_insight[:profile_views].blank?
          user_insight[:profile_views] = {'total_views' => 0, 'company_views' => [],'date_views' => []}
        end
        # updating profile view impressions
        profile_view_impressions =
            Instrumentation.where(:event_name => 'Consumer.Profile.ViewProfile').
                            where('event_payload.handle' => user[:handle])
        if profile_view_impressions.blank?
          next
        end
        profile_views = {'total_views' => 0, 'company_views' => [],'date_views' => []};
        profile_views["total_views"] = profile_view_impressions.count()
        day_views = profile_view_impressions.map_reduce(UserInsightsHelper::InsightsForUser::Date_count_map, UserInsightsHelper::InsightsForUser::Date_count_reduce).out(inline: true).to_a
        day_views = day_views.map { |data| {:date => Date.strptime(data["_id"], "%d-%m-%Y").to_s, :count => data["value"]}}
        profile_views["date_views"] = day_views.sort_by { |day_view| day_view[:date]}
        company_views = profile_view_impressions.group_by{|impression| get_company_by_job_id(impression[:event_payload]['token'])}.delete_if{|key, value| key.blank?};
        company_views = company_views.map{|key, value| {:company => key[:name], :count => value.count()}};
        profile_views["company_views"] = company_views.sort_by{|company_view| -company_view[:count]};
        user_insight[:profile_views] = profile_views;
        user_insight.save!
      end
    end
  end