# scrapes required data from linkedin

require './OfflineScripts/lib/utils.rb'
require 'json/pure'
require 'thread/pool'
require 'HTMLEntities'
require 'nokogiri'
include Util

Headers = {
    "Proxy-Connection" => "keep-alive",
    "Cache-Control" => "max-age=0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
    "Accept-Language" => "en-US,en;q=0.8",
    "cookie" => 'bcookie="v=2&51a799c1-079f-494b-8b21-770f71739ddb"; bscookie="v=1&2014072622013851b75a98-838f-4a08-82c9-8791d1ffb847AQH_bMXK1YkXHmcTjpUJ9cpOQ8Llvih_"; __qca=P0-2119175182-1406417742711; visit="v=1&M"; L1c=5896cb41; L1l=54d34b36; csrftoken=M0137hByZRzreVZZSwScs6q74PhUssEe; L1e=203e6005; sdsc=1%3A1SZM1shxDNbLt36wZwCgPgvN58iw%3D; X-ATS-Node-0=0; X-ATS-Node-1=0; X-ATS-Node-2=0; sessionid="eyJkamFuZ29fdGltZXpvbmUiOiJBc2lhL0tvbGthdGEifQ:1XSJJi:ksV0E5eTlk0-bOCWX-Za1pr-_Q4"; __utma=23068709.267955427.1410685079.1410737413.1410745540.3; __utmc=23068709; __utmz=23068709.1410685079.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utmv=23068709.user; _lipt=0_4C3jbv-a6evxSRibGVmvrhX3dUQSNG8QW4m-KnfwvJKe5-wMrpXNftj2ZuWzgI1FZQzTAnDkvVVYkxi6D3ezKDNbLSpVrgqnDz-uEoxF8WkF1CIwqnx-kgJEgglhhUdVYEvXviYKDAINRLbFLt4jbUqc63I23zdkxMp7JLH7qBt9Hp1vpseWFocWeXtN0YoSSjaxaYpBoBOBc2s353IxgLbYhsj8JEKML-duTd2KieqQgDarZgl-D6UuY7tJOtSeL5qYF26rdaNG2z0dU9gTMssyLaWd8UM8kTGefs8TOSf; lang="v=2&lang=en-us&c="; li_at="AQECAQMpjkcCLXXPAAABSHb8wNcAAAFIf3IjXUuw11Yw6iTRDfhUAZoTZZOh-qGuFNwF-P0hYr5-nhhMe6H3p9L3zKAhBFEav_wraGcvoob8dLP5i7TGxGjf61ocPkdlLkZwdaAKaMlrBM4JJgsU4ro"; sl="v=1&5donw"; JSESSIONID="ajax:7191457081045638447"; lidc="b=LB47:g=116:u=39:i=1410880259:t=1410966659:s=AQFMHlfV_h7KZddqWZQuf9wVl5KMxG7P"; RT=s=1410880259729&r=https%3A%2F%2Fwww.linkedin.com%2F'
}

Base_URL = 'https://www.linkedin.com'
SCHOOL_SEARCH_URL = '/ta/school'
ALUMNI_SEARCH_URL = '/edu/alumni'
ThreadPoolLimit = 5
QPS = 0.5

def get_school_ids
  schools = School.all().to_a;
  school_search_url = URI.join(Base_URL, SCHOOL_SEARCH_URL);
  school_ids = []
  schools.each do |school|
    url_param = {}
    url_param["query"] =school[:name];
    response = makeHttpRequest(school_search_url, Headers, url_param, nil)
    if response.blank? || response.code != "200"
      next
    end
    result = JSON.parse(response.body());
    if result.blank? || result["resultList"].count() == 0
      next
    end
    # taking the first result
    school_ids.push({'resume_id' => school[:_id], 'linkedin_id' => result['resultList'][0]['id']});
  end
  return school_ids
end

def get_detailed_stats(resume_school_id, linkedin_id, company, study, year)
  url_param = {}
  url_param['id'] = linkedin_id
  # limiting to US and Engineering
  url_param['facets'] = 'G.us:0';
  url_param['facets'] += ',CN.8';
  url_param['facets'] += ",CC.%s" % company['code']
  url_param['facets'] += ",FS.%s" % study['code']
  url_param['dateType'] ='graduated'
  url_param['endYear'] = year
  alumni_search_url = URI.join(Base_URL, ALUMNI_SEARCH_URL)
  response = makeHttpRequest(alumni_search_url, Headers, url_param, nil, QPS)
  if response.blank? || response.code != '200'
    return nil
  end
  doc = Nokogiri::HTML(response.body());
  content = doc.at_xpath("//code[@id='plato-alumni-by-school-content']").children()[0].inner_text;
  content = content.gsub /"distance":\\u002d1,/, '';
  json_content = JSON.parse(content);

  current_companies = [];
  current_study = [];
  current_skills = [];
  if (!json_content["content"]["alumniBySchool"]["facets"][1].blank?)
    current_companies = json_content["content"]["alumniBySchool"]["facets"][1]['buckets'];
  end
  if (!json_content["content"]["alumniBySchool"]["facets"][3].blank?)
    current_study = json_content["content"]["alumniBySchool"]["facets"][3]['buckets'];
  end
  if (!json_content["content"]["alumniBySchool"]["facets"][4].blank?)
    current_skills = json_content["content"]["alumniBySchool"]["facets"][4]['buckets'];
  end
  print "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" %[resume_school_id, linkedin_id, company, study, year, current_companies, current_study, current_skills];
end

def get_generic_stats(school_id)
  url_param = {}
  url_param['id'] = school_id['linkedin_id'];
  # limiting to US and Engineering
  url_param["facets"] = "G.us:0,CN.8";
  alumni_search_url = URI.join(Base_URL, ALUMNI_SEARCH_URL)
  response = makeHttpRequest(alumni_search_url, Headers, url_param, nil)
  if response.blank? || response.code != '200'
    return nil
  end
  doc = Nokogiri::HTML(response.body());
  content = doc.at_xpath("//code[@id='plato-alumni-by-school-content']").children()[0].inner_text;
  content = content.gsub /"distance":\\u002d1,/, '';
  json_content = JSON.parse(content);
  companies = [];
  study = [];
  skills = [];
  if (json_content.blank? ||
      json_content["content"].blank? ||
      json_content["content"]["alumniBySchool"].blank? ||
      json_content["content"]["alumniBySchool"]["facets"].blank? ||
      json_content["content"]["alumniBySchool"]["facets"].count() <= 4)
    return nil
  end
  if (!json_content["content"]["alumniBySchool"]["facets"][1].blank?)
    companies = json_content["content"]["alumniBySchool"]["facets"][1]['buckets'];
  end
  if (!json_content["content"]["alumniBySchool"]["facets"][3].blank?)
    study = json_content["content"]["alumniBySchool"]["facets"][3]['buckets'];
  end
  if (!json_content["content"]["alumniBySchool"]["facets"][4].blank?)
    skills = json_content["content"]["alumniBySchool"]["facets"][4]['buckets'];
  end
  school_info = {}
  school_info['linkedin_id'] = school_id['linkedin_id']
  school_info['resume_id'] = school_id['resume_id']
  school_info['companies'] = companies;
  school_info['study'] = study;
  school_info['skills'] = skills;
  return school_info
end


# Main program starts here
# HACK limiting to 1 schools
#school_ids = get_school_ids();
school_ids = [{"resume_id"=>"caltech", "linkedin_id"=>"17811"}, {"resume_id"=>"gatech", "linkedin_id"=>"18158"}, {"resume_id"=>"illinois", "linkedin_id"=>"18321"}, {"resume_id"=>"princeton", "linkedin_id"=>"18867"}, {"resume_id"=>"cornell", "linkedin_id"=>"18946"}, {"resume_id"=>"usc", "linkedin_id"=>"17971"}, {"resume_id"=>"ucla", "linkedin_id"=>"17950"}, {"resume_id"=>"berkeley", "linkedin_id"=>"17939"}, {"resume_id"=>"ufl", "linkedin_id"=>"18120"}, {"resume_id"=>"northwestern", "linkedin_id"=>"18290"}, {"resume_id"=>"stanford", "linkedin_id"=>"17926"}, {"resume_id"=>"mit", "linkedin_id"=>"18494"}, {"resume_id"=>"rice", "linkedin_id"=>"19472"}, {"resume_id"=>"brown", "linkedin_id"=>"19348"}, {"resume_id"=>"duke", "linkedin_id"=>"18765"}, {"resume_id"=>"harvard", "linkedin_id"=>"18483"}, {"resume_id"=>"columbia", "linkedin_id"=>"18943"}, {"resume_id"=>"cmu", "linkedin_id"=>"19232"}, {"resume_id"=>"nyu", "linkedin_id"=>"18993"}, {"resume_id"=>"yale", "linkedin_id"=>"18043"}, {"resume_id"=>"uw", "linkedin_id"=>"19657"}, {"resume_id"=>"upenn", "linkedin_id"=>"19328"}, {"resume_id"=>"umass", "linkedin_id"=>"18526"}, {"resume_id"=>"utexas", "linkedin_id"=>"19518"}, {"resume_id"=>"uwaterloo", "linkedin_id"=>"10875"}, {"resume_id"=>"umich", "linkedin_id"=>"18633"}, {"resume_id"=>"ucsd", "linkedin_id"=>"17954"}];
# getting generic stats for each school
generic_stats = school_ids.map{ |school_id| get_generic_stats(school_id)};

# looping through last 10 years
final_stats = []
pool = Thread.pool(ThreadPoolLimit);
(2004..2004).each do |year|
  generic_stats.each do |school_stat|
    company_count = [school_stat['companies'].count(),10].min()
    study_count = [school_stat['study'].count(),5].min()
    (1..company_count).each do |company_index|
      (1..study_count).each do |study_index|
        pool.process{
        get_detailed_stats(
            school_stat['resume_id'],
            school_stat['linkedin_id'],
            school_stat['companies'][company_index],
            school_stat['study'][study_index],
            year)
        };
      end
    end
  end
end
pool.shutdown;

