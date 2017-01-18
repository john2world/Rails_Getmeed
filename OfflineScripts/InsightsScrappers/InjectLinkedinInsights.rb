require './app/managers/jobs/jobs_manager.rb'
require 'thread/pool'
include JobsManager
filename = "/Users/ViswaMani/futura-project/linkedin_data_1.tsv";
ThreadPoolLimit = 15;
$stderr.puts "Parsing filename #{filename}";
pool = Thread.pool(ThreadPoolLimit);
def process_line(line)
  cols = line.strip().split("\t");
  school_id = cols[0];
  company_name = eval(cols[2])["name"];
  # find companies in company table
  company = Company.find_by(name: company_name);
  if company.blank?
    company = get_or_create_company(company_name, nil);
    company[:company_id] = company[:_id];
    company.save();
  end
  company_id = company[:_id]
  major_name = eval(cols[3])["name"];
  major = Major.find_by(major: major_name);
  if major.blank?
    $stderr.puts "Missing major: #{major_name}"
    return
  end
  major_id = major[:_id]
  year = cols[4].to_i;
  companies_by_major = eval(cols[5]);
  majors_by_company = eval(cols[6]);
  skills = eval(cols[7]);
  # creating company insight
  company_insight = CompanyInsights.find(school_id+"_"+company_id+"_"+year.to_s);
  if company_insight.blank?
    company_insight = CompanyInsights.new(school_id: school_id, company_id: company_id, year: year);
  end
  # overriding old data with new if any
  company_insight[:major_counts] = majors_by_company.map{ |major_data|
    majorid = Major.find_by(major: major_data["name"]);
    majorid = major_id.blank?? majorid[:_id] : nil;
    {:major => major_data["name"], :count => major_data["count"], :id => majorid}
  }
  skill_counts = skills.map{ |skill|
    {:skill => skill["name"], :count => skill["count"]}
  };

  # merging the skill counts
  if company_insight[:skill_counts].blank?
    company_insight[:skill_counts] = []
  end
  company_insight[:skill_counts] = (company_insight[:skill_counts] + skill_counts).group_by{|i| i[:skill]}.
      map{ |key, value|
    {:skill => key, :count => value.map{|v| v[:count]}.sum()}
  };
  company_insight.save();

  # creating Major insight
  major_insight = MajorInsights.find(school_id+"_"+major_id+"_"+year.to_s);
  if major_insight.blank?
    major_insight = MajorInsights.new(school_id: school_id, major_id: major_id, year: year);
  end
  # overriding old data with new if any
  major_insight[:company_counts] = companies_by_major.map{ |company_data|
    companyid = Company.find_by(name: company_data["name"]);
    companyid = companyid.blank?? nil : companyid[:_id];
    {:company => company_data["name"], :count => company_data["count"], :id => companyid}
  }
  skill_counts = skills.map{ |skill|
    {:skill => skill["name"], :count => skill["count"]}
  }
  if major_insight[:skill_counts].blank?
    major_insight[:skill_counts] = [];
  end
  major_insight[:skill_counts] = (major_insight[:skill_counts] + skill_counts).group_by{|i| i[:skill]}.map{ |key, value|
    {:skill => key, :count => value.map{|v| v[:count]}.sum()}
  };
  major_insight.save();
end
File.readlines(filename).each do |line|
  pool.process{process_line(line)}
end
# waiting for the pools to finish
pool.shutdown;
$stderr.puts "finished parsing lines";