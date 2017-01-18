# Get the Comapnies from the company DB
require './OfflineScripts/lib/utils.rb'
require 'json'
require 'thread/pool'
include Util

API_BASE_URL = 'http://api.glassdoor.com'
API_PATH_URL = '/api/api.htm'
URL_PARAMS = {
    't.p' => '23272',
    't.k' => 'iOvgyJUE6hO',
    'userip' => '0.0.0.0',
    'useragent' => '',
    'format' => 'json',
    'v' => '1',
    'action' => 'employers',
    'q' => ''}
ThreadPoolLimit = 5

def search_company(company_name)
  #$stderr.puts "searching for company #{company_name}"
  url_params = URL_PARAMS.clone();
  url_params["q"] = company_name;
  url =  URI.join(API_BASE_URL, API_PATH_URL)
  response = makeHttpRequest(url, nil, url_params, nil, 1, nil);
  if !response.blank?
    parsed_response = JSON.parse(response.body);
    if (!parsed_response["success"] || parsed_response["response"].blank?)
      $stderr.puts "found nothing for company #{company_name}"
      return
    end
    parsed_response["response"]["employers"].each do |employer|
      # getting only exact match employers
      if !employer["exactMatch"]
        continue
      end
      puts employer;
    end
  else
    $stderr.puts "response blank for company #{company_name}"
  end
end

pool = Thread.pool(ThreadPoolLimit);
#company_names = Company.all().pluck(:name);
company_names = ["Lot18","Electric Imp","Apsalar","GigsTime","MyThings","Braintree","Beyondsoft","FloDesign Wind Turbine","Delivery Hero","CNE Media","AlienVault"]
company_names.each do |company_name|
  pool.process{search_company(company_name)};
end
# waiting for the pools to finish
pool.shutdown;

