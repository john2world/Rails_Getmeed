require './app/managers/jobs/jobs_manager.rb'
require 'thread/pool'
include JobsManager

directory = '/Users/ViswaMani/futura-project/';
generic_stats_filename = directory+'glass_door_stats.txt';
salary_stats_filename = directory+'glass_door_salary_data.txt';
interview_stats_filename = directory+'glass_door_interview_stats_data.txt';
benefits_stats_filename = directory+'glass_door_benefits_data.txt';

ThreadPoolLimit = 15;

GLASSDOOR_COMPANYID_MAPPING = {}

def process_generic_stats(line)
  if line.blank?
    return
  end
  stats = eval(line);
  if stats['name'].blank?
    return
  end
  company = Company.find_by(name: stats['name']);
  if company.blank?
    company = get_or_create_company(stats['name'], nil);
    company[:company_id] = company[:_id];
    company.save();
  end
  # update glass door mapping
  GLASSDOOR_COMPANYID_MAPPING[stats['id']] = company[:_id];

  company_insight = CompanyInsights.find_or_create_by(company_id: company[:_id]);

  ratings_insight = [];
  # update ratings
  if company_insight[:ratings].blank?
    company_insight[:ratings] = [];
  end
  stats.each_key { |key|
    if (key.ends_with? "Rating")
      key_string = key.underscore.gsub('_', " ").titleize();
      ratings_insight.push({:name => key_string, :value => stats[key].to_f});
    end
  }

  if !stats['ceo'].blank?
    ratings_insight.push({:name => "CEO (#{stats['ceo']['name']}) Rating", :value => stats['ceo']['pctApprove'].to_i});
  end
  # remove duplicates if any
  company_insight[:ratings] = ratings_insight.uniq;

  review_ratings = []
  # update reviews
  if company_insight[:reviews].blank?
    company_insight[:reviews] = [];
  end
  if (!stats['featuredReview'].blank?)
    review_ratings.push(stats['featuredReview']);
  end

  company_insight[:reviews] = review_ratings;

  if (company_insight[:sources].blank?)
    company_insight[:sources] = [];
  end
  company_insight[:sources] = company_insight[:sources].push({:name => "glassdoor", :id=>stats["id"]}).uniq;

  if (company_insight[:salary].blank?)
    company_insight[:salary] = [];
  end

  if (company_insight[:benefits].blank?)
    company_insight[:benefits] = {};
  end

  if (company_insight[:interview].blank?)
    company_insight[:interview] = {};
  end
  company_insight.save();
end
def process_benefits_stats(line)
  if line.blank?
    return
  end
  stats = eval(line);
  if !GLASSDOOR_COMPANYID_MAPPING.has_key? stats['company_id']
    return
  end
  company_insight = CompanyInsights.find_or_create_by(company_id: GLASSDOOR_COMPANYID_MAPPING[stats['company_id']]);

  insight = {}
  insight[:rating] = stats['benefitRatingPercentage'].to_f;
  insight[:top_benefits] = stats['topBenefits'].map{|benefit| benefit['name']};
  company_insight[:benefits] = insight;
  company_insight.save()
end
def process_interview_stats(line)
  if line.blank?
    return
  end
  stats = eval(line)
  if !GLASSDOOR_COMPANYID_MAPPING.has_key? stats['company_id']
    return
  end
  company_insight = CompanyInsights.find_or_create_by(company_id: GLASSDOOR_COMPANYID_MAPPING[stats['company_id']]);

  insight = {}
  insight[:difficulty] = stats['difficulty'].to_f;
  insight[:experience] = {}
  if !stats['experience'].blank? && !stats['experience']['Positive'].blank?
    insight[:experience][:positive] = stats['experience']['Positive'].to_f;
  end
  if !stats['experience'].blank? && !stats['experience']['Negative'].blank?
    insight[:experience][:negative] = stats['experience']['Negative'].to_f;
  end
  if !stats['experience'].blank? && !stats['experience']['Neutral'].blank?
    insight[:experience][:neutral] = stats['experience']['Neutral'].to_f;
  end

  insight[:source] = {}
  stats['acquisition'] = stats['acquisition'].select{|key, value| !value.blank?};
  stats['acquisition'].each_key{|key| stats['acquisition'][key] = stats['acquisition'][key].to_f};
  insight[:source] = stats['acquisition'];

  company_insight[:interview] = insight;
  company_insight.save()
end
def process_salary_stats(line)
  if line.blank?
    return
  end
  stats = eval(line)
  if !GLASSDOOR_COMPANYID_MAPPING.has_key? stats['company_id']
    return
  end
  company_insight = CompanyInsights.find_or_create_by(company_id: GLASSDOOR_COMPANYID_MAPPING[stats['company_id']]);

  if company_insight[:salary].blank?
    company_insight[:salary] = []
  end
  insight = {};
  insight[:job_title] = stats['job_title'];
  if stats['job_title'].downcase().include? " intern"
    insight[:job_type] = "Intern";
  else
    insight[:job_type] = stats['job_type'];
  end
  insight[:min] = stats['min_salary'];
  insight[:max] = stats['max_salary'];
  insight[:mean] = stats['mean_salary'];
  insight[:details] = stats['salary_details'];
  company_insight.push(:salary, insight);
  company_insight.save();
end

generic_stats_pool = Thread.pool(ThreadPoolLimit);
# reading generic stats
File.readlines(generic_stats_filename).each do |line|
  generic_stats_pool.process{process_generic_stats(line)}
end
# waiting for the pools to finish
generic_stats_pool.shutdown

benefits_stats_pool = Thread.pool(ThreadPoolLimit);
File.readlines(benefits_stats_filename).each do |line|
  benefits_stats_pool.process{process_benefits_stats(line)}
end
# waiting for the pools to finish
benefits_stats_pool.shutdown

interview_stats_pool = Thread.pool(ThreadPoolLimit);
File.readlines(interview_stats_filename).each do |line|
  interview_stats_pool.process{process_interview_stats(line)}
end
# waiting for the pools to finish
interview_stats_pool.shutdown

File.readlines(salary_stats_filename).each do |line|
  process_salary_stats(line)
end