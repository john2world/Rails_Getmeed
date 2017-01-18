# Computes the all the necessary features for Profile score model
# Estimates the parameters for the profile score model and updates the model file
namespace :model_updates do
  task update_profile_score_model: :environment do
    require "#{Rails.root}/app/helpers/models/profile_score_helper.rb"
    include Models::ProfileScoreHelper
    model_weights = {}
    # Model Weights
    model_weights["objective"]=0.05;
    model_weights["workExp_count"]=0.15;
    model_weights["workExp_duration"]=0.15;
    model_weights["workExp_skillCount"]=0.1;
    model_weights["internship_count"]=0.15;
    model_weights["internship_duration"]=0.15;
    model_weights["internship_skillCount"]=0.1;
    model_weights["pub_count"]=0.05;
    model_weights["courses_count"]=0.05;
    model_weights["edu_years"]=0.05;
    model_weights["gpa"]=0.1;

    puts "\n\n"

    # printing Model Weights
    puts "# Model Weights"
    model_weights.each do |key, value|
      puts "#{key}\t#{value}"
    end

    puts "# Model parameters"
    # Model parameters
    features = Profile.all.to_a.map { |profile| featurize(profile) }.compact;
    features_by_school = features.group_by { |feature| feature[:school] };
    features_by_school.each do |key, values|
      objective_stats = values.map { |value| value[:objective].blank? ? 0 : value[:objective] }.compact;
      puts "#{key}\tobjective\t#{objective_stats.mean}\t#{objective_stats.standard_deviation}";

      workExp_count_stats = values.map { |value| value[:workExp_count].blank? ? 0 : value[:workExp_count] }.compact;
      puts "#{key}\tworkExp_count\t#{workExp_count_stats.mean}\t#{workExp_count_stats.standard_deviation}";

      workExp_duration_stats = values.map { |value| value[:workExp_duration].blank? ? 0 : value[:workExp_duration] }.compact;
      puts "#{key}\tworkExp_duration\t#{workExp_duration_stats.mean}\t#{workExp_duration_stats.standard_deviation}";

      workExp_skillCount_stats = values.map { |value| value[:workExp_skillCount].blank? ? 0 : value[:workExp_skillCount] }.compact;
      puts "#{key}\tworkExp_skillCount\t#{workExp_skillCount_stats.mean}\t#{workExp_skillCount_stats.standard_deviation}";

      internship_count_stats = values.map { |value| value[:internship_count].blank? ? 0 : value[:internship_count] }.compact;
      puts "#{key}\tinternship_count\t#{internship_count_stats.mean}\t#{internship_count_stats.standard_deviation}";

      internship_duration_stats = values.map { |value| value[:internship_duration].blank? ? 0 : value[:internship_duration] }.compact;
      puts "#{key}\tinternship_duration\t#{internship_duration_stats.mean}\t#{internship_duration_stats.standard_deviation}";

      internship_skillCount_stats = values.map { |value| value[:internship_skillCount].blank? ? 0 : value[:internship_skillCount] }.compact;
      puts "#{key}\tinternship_skillCount\t#{internship_skillCount_stats.mean}\t#{internship_skillCount_stats.standard_deviation}";

      pub_count_stats = values.map { |value| value[:pub_count].blank? ? 0 : value[:pub_count] }.compact;
      puts "#{key}\tpub_count\t#{pub_count_stats.mean}\t#{pub_count_stats.standard_deviation}";

      courses_count_stats = values.map { |value| value[:courses_count].blank? ? 0 : value[:courses_count] }.compact;
      puts "#{key}\tcourses_count\t#{courses_count_stats.mean}\t#{courses_count_stats.standard_deviation}";

      edu_years_stats = values.map { |value| value[:edu_years].blank? ? 0 : value[:edu_years] };
      puts "#{key}\tedu_years\t#{edu_years_stats.mean}\t#{edu_years_stats.standard_deviation}";

      gpa_stats = values.map { |value| value[:gpa].blank? ? 0 : value[:gpa] }.compact;
      puts "#{key}\tgpa\t#{gpa_stats.mean}\t#{gpa_stats.standard_deviation}";
    end
  end
  task update_profile_score: :environment do
    require "#{Rails.root}/app/helpers/profiles_helper.rb"
    include ProfilesHelper
    profiles = Profile.all
    profiles.each do |profile|
        update_score(profile)
        profile.save!
    end
  end
end