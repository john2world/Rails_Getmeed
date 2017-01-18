FileName = "scrape_results.txt"
Cookie = "__ar_v4=%7C3GKXIEUXWJAK5PMC2VVL7T%3A20140708%3A1%7CG3EIAJLTYVGBJNTJNZCIEZ%3A20140708%3A1%7CWI2NJ2OZKJELRIMUNEUNL5%3A20140708%3A1; session=ndrfkeblmh26q6jc5ffgu24852; ln=dc6d735bf32ab481853b71c4bc2b7c15df26578c%7EZoQcpFXrfyAGA1J1G7zmoB1qeZZrEbpL6JfmR7gbIUg%3D; _ga=GA1.2.1323943901.1404882479"
######### SCRAPE COMPANIES #########
# counter = 0
# (0..228354).step(50).to_a.each do |count|
#   cmdline = "curl -X POST --data \"aoData[sEcho]=1&aoData[iColumns]=44&aoData[sColumns]=&aoData[iDisplayStart]=#{count}&aoData[iDisplayLength]=50&aoData[mDataProp_0]=company_name&aoData[mDataProp_1]=domain&aoData[mDataProp_2]=mattermark_score&aoData[mDataProp_3]=custom_score&aoData[mDataProp_4]=momentum_score&aoData[mDataProp_5]=is_raising&aoData[mDataProp_6]=raising_amount&aoData[mDataProp_7]=pre_money_valuation&aoData[mDataProp_8]=raised_amount&aoData[mDataProp_9]=employees&aoData[mDataProp_10]=employees_month_ago&aoData[mDataProp_11]=employees_added_in_month&aoData[mDataProp_12]=employees_mom&aoData[mDataProp_13]=cached_uniques&aoData[mDataProp_14]=cached_uniques_week_ago&aoData[mDataProp_15]=uniques_wow&aoData[mDataProp_16]=cached_uniques_month_ago&aoData[mDataProp_17]=uniques_mom&aoData[mDataProp_18]=cached_mobile_downloads&aoData[mDataProp_19]=cached_mobile_downloads_week_ago&aoData[mDataProp_20]=mobile_downloads_wow&aoData[mDataProp_21]=cached_mobile_downloads_month_ago&aoData[mDataProp_22]=mobile_downloads_mom&aoData[mDataProp_23]=cached_mobile_mattermark&aoData[mDataProp_24]=est_founding_date&aoData[mDataProp_25]=stage&aoData[mDataProp_26]=investors&aoData[mDataProp_27]=total_funding&aoData[mDataProp_28]=last_funding_date&aoData[mDataProp_29]=last_funding_amount&aoData[mDataProp_30]=location&aoData[mDataProp_31]=city&aoData[mDataProp_32]=region&aoData[mDataProp_33]=state&aoData[mDataProp_34]=country&aoData[mDataProp_35]=continent&aoData[mDataProp_36]=business_models&aoData[mDataProp_37]=industries&aoData[mDataProp_38]=keywords&aoData[mDataProp_39]=interested&aoData[mDataProp_40]=alert_hash&aoData[mDataProp_41]=user_tags&aoData[mDataProp_42]=keywords&aoData[mDataProp_43]=has_mobile&aoData[sSearch]=&aoData[bRegex]=false&aoData[sSearch_0]=&aoData[bRegex_0]=false&aoData[bSearchable_0]=true&aoData[sSearch_1]=&aoData[bRegex_1]=false&aoData[bSearchable_1]=true&aoData[sSearch_2]=&aoData[bRegex_2]=false&aoData[bSearchable_2]=true&aoData[sSearch_3]=&aoData[bRegex_3]=false&aoData[bSearchable_3]=true&aoData[sSearch_4]=&aoData[bRegex_4]=false&aoData[bSearchable_4]=true&aoData[sSearch_5]=&aoData[bRegex_5]=false&aoData[bSearchable_5]=true&aoData[sSearch_6]=&aoData[bRegex_6]=false&aoData[bSearchable_6]=true&aoData[sSearch_7]=&aoData[bRegex_7]=false&aoData[bSearchable_7]=true&aoData[sSearch_8]=&aoData[bRegex_8]=false&aoData[bSearchable_8]=true&aoData[sSearch_9]=&aoData[bRegex_9]=false&aoData[bSearchable_9]=true&aoData[sSearch_10]=&aoData[bRegex_10]=false&aoData[bSearchable_10]=true&aoData[sSearch_11]=&aoData[bRegex_11]=false&aoData[bSearchable_11]=true&aoData[sSearch_12]=&aoData[bRegex_12]=false&aoData[bSearchable_12]=true&aoData[sSearch_13]=&aoData[bRegex_13]=false&aoData[bSearchable_13]=true&aoData[sSearch_14]=&aoData[bRegex_14]=false&aoData[bSearchable_14]=true&aoData[sSearch_15]=&aoData[bRegex_15]=false&aoData[bSearchable_15]=true&aoData[sSearch_16]=&aoData[bRegex_16]=false&aoData[bSearchable_16]=true&aoData[sSearch_17]=&aoData[bRegex_17]=false&aoData[bSearchable_17]=true&aoData[sSearch_18]=&aoData[bRegex_18]=false&aoData[bSearchable_18]=true&aoData[sSearch_19]=&aoData[bRegex_19]=false&aoData[bSearchable_19]=true&aoData[sSearch_20]=&aoData[bRegex_20]=false&aoData[bSearchable_20]=true&aoData[sSearch_21]=&aoData[bRegex_21]=false&aoData[bSearchable_21]=true&aoData[sSearch_22]=&aoData[bRegex_22]=false&aoData[bSearchable_22]=true&aoData[sSearch_23]=&aoData[bRegex_23]=false&aoData[bSearchable_23]=true&aoData[sSearch_24]=&aoData[bRegex_24]=false&aoData[bSearchable_24]=true&aoData[sSearch_25]=&aoData[bRegex_25]=false&aoData[bSearchable_25]=true&aoData[sSearch_26]=&aoData[bRegex_26]=false&aoData[bSearchable_26]=true&aoData[sSearch_27]=&aoData[bRegex_27]=false&aoData[bSearchable_27]=true&aoData[sSearch_28]=&aoData[bRegex_28]=false&aoData[bSearchable_28]=true&aoData[sSearch_29]=&aoData[bRegex_29]=false&aoData[bSearchable_29]=true&aoData[sSearch_30]=&aoData[bRegex_30]=false&aoData[bSearchable_30]=true&aoData[sSearch_31]=&aoData[bRegex_31]=false&aoData[bSearchable_31]=true&aoData[sSearch_32]=&aoData[bRegex_32]=false&aoData[bSearchable_32]=true&aoData[sSearch_33]=&aoData[bRegex_33]=false&aoData[bSearchable_33]=true&aoData[sSearch_34]=&aoData[bRegex_34]=false&aoData[bSearchable_34]=true&aoData[sSearch_35]=&aoData[bRegex_35]=false&aoData[bSearchable_35]=true&aoData[sSearch_36]=&aoData[bRegex_36]=false&aoData[bSearchable_36]=true&aoData[sSearch_37]=&aoData[bRegex_37]=false&aoData[bSearchable_37]=true&aoData[sSearch_38]=&aoData[bRegex_38]=false&aoData[bSearchable_38]=true&aoData[sSearch_39]=&aoData[bRegex_39]=false&aoData[bSearchable_39]=true&aoData[sSearch_40]=&aoData[bRegex_40]=false&aoData[bSearchable_40]=true&aoData[sSearch_41]=&aoData[bRegex_41]=false&aoData[bSearchable_41]=true&aoData[sSearch_42]=&aoData[bRegex_42]=false&aoData[bSearchable_42]=true&aoData[sSearch_43]=&aoData[bRegex_43]=false&aoData[bSearchable_43]=true&aoData[iSortCol_0]=2&aoData[sSortDir_0]=desc&aoData[iSortingCols]=1&aoData[bSortable_0]=true&aoData[bSortable_1]=true&aoData[bSortable_2]=true&aoData[bSortable_3]=true&aoData[bSortable_4]=true&aoData[bSortable_5]=true&aoData[bSortable_6]=true&aoData[bSortable_7]=true&aoData[bSortable_8]=true&aoData[bSortable_9]=true&aoData[bSortable_10]=true&aoData[bSortable_11]=true&aoData[bSortable_12]=true&aoData[bSortable_13]=true&aoData[bSortable_14]=true&aoData[bSortable_15]=true&aoData[bSortable_16]=true&aoData[bSortable_17]=true&aoData[bSortable_18]=true&aoData[bSortable_19]=true&aoData[bSortable_20]=true&aoData[bSortable_21]=true&aoData[bSortable_22]=true&aoData[bSortable_23]=true&aoData[bSortable_24]=true&aoData[bSortable_25]=true&aoData[bSortable_26]=true&aoData[bSortable_27]=true&aoData[bSortable_28]=true&aoData[bSortable_29]=true&aoData[bSortable_30]=true&aoData[bSortable_31]=true&aoData[bSortable_32]=true&aoData[bSortable_33]=true&aoData[bSortable_34]=true&aoData[bSortable_35]=true&aoData[bSortable_36]=true&aoData[bSortable_37]=true&aoData[bSortable_38]=true&aoData[bSortable_39]=true&aoData[bSortable_40]=true&aoData[bSortable_41]=true&aoData[bSortable_42]=true&aoData[bSortable_43]=true&aoData[sharing_key]=&treeQuery[boolean]=AND&treeQuery[members][0][field]=stage&treeQuery[members][0][operator]=!=&treeQuery[members][0][value]=Exited&treeQuery[members][1][field]=interested&treeQuery[members][1][operator]=!=&treeQuery[members][1][value]=0&es=false&customScoreWeights[web]=0&customScoreWeights[mobile_downloads]=1&customScoreWeights[twitter_mentions]=1&customScoreWeights[facebook_talking_count]=0&customScoreWeights[employees]=0\" http://mattermark.com/app/data/get/ -H \"X-Requested-With: XMLHttpRequest\" -H \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36\" -H \"Content-Type: application/x-www-form-urlencoded; charset=UTF-8\" -H \"Referer: https://mattermark.com/app/data?operator[0]=stage%09!%3D%09Exited&operator[1]=interested%09!%3D%090&score_mobile_downloads=1&score_twitter_mentions=1\" -H \"Accept-Language: en-US,en;q=0.8\" -H \"Cookie: #{Cookie}\" >> #{FileName}"
#   puts cmdline
#   puts "echo -e \"\n\" >> #{FileName}"
#   counter += 1
#   if counter == 50
#     puts "sleep 1"
#     counter = 0
#   end
# end
######## TO GET COMPANY DATA ######
# company_ids = File.readlines("mattermark_company_ids.txt").map {|line| line.chomp};
# company_ids.each do |company_id|
#   cmdline = "curl -X GET https://mattermark.com/app/data/#{company_id}/scores -H \"X-Requested-With: XMLHttpRequest\" -H \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36\" -H \"Content-Type: application/x-www-form-urlencoded; charset=UTF-8\" -H \"Referer: https://mattermark.com/app/data?operator[0]=stage%09!%3D%09Exited&operator[1]=interested%09!%3D%090&score_mobile_downloads=1&score_twitter_mentions=1\" -H \"Accept-Language: en-US,en;q=0.8\" -H \"Cookie: #{Cookie}\" >> #{FileName}"
#   puts cmdline
#   puts "echo -e \"\n\" >> #{FileName}"
# end
####################################

######## Get LinkedinIds ###########
# company_ids = File.readlines("mattermark_company_ids.txt").map {|line| line.chomp};
# company_ids.each do |company_id|
#   cmdline = "curl -X GET https://mattermark.com/app/data/#{company_id}/buffer -H \"X-Requested-With: XMLHttpRequest\" -H \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36\" -H \"Content-Type: application/x-www-form-urlencoded; charset=UTF-8\" -H \"Referer: https://mattermark.com/app/data?operator[0]=stage%09!%3D%09Exited&operator[1]=interested%09!%3D%090&score_mobile_downloads=1&score_twitter_mentions=1\" -H \"Accept-Language: en-US,en;q=0.8\" -H \"Cookie: #{Cookie}\""
#   extra = "|perl -ne '/\\/app\\/LinkedIn\\/who_i_know_at\\?linkedin_company_id=(\\d+)&company_name=(.+)'+\"'\"+'/; $company_name = $2; $company_id = $1; if ($company_id ne \"\") {print \"#{company_id}\\t$company_id\\t$company_name\\n\";}'|uniq"
#   puts cmdline+extra+" >> #{FileName}"
# end

########## TO GET COMPANY CONTACTS ##########
#linkedinIds = File.readlines("mattermark_linkedin_ids.txt").map{|line| line.split("\t")}
# linkedinIds.each do |companyid, linkedinId, companyname|
#   puts "echo -e \"#{companyid}\\t#{linkedinId}\\t#{companyname.chomp()}\\t\" >> #{FileName}"
#   cmdline = "curl -X GET \"https://mattermark.com/app/LinkedIn/who_i_know_at?linkedin_company_id=#{linkedinId}&company_name=#{companyname.chomp()}\" -H \"X-Requested-With: XMLHttpRequest\" -H \"User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36\" -H \"Content-Type: application/x-www-form-urlencoded; charset=UTF-8\" -H \"Referer: https://mattermark.com/app/data?operator[0]=stage%09!%3D%09Exited&operator[1]=interested%09!%3D%090&score_mobile_downloads=1&score_twitter_mentions=1\" -H \"Accept-Language: en-US,en;q=0.8\" -H \"Cookie: #{Cookie}\" >> #{FileName}"
#   puts cmdline
#   puts "echo -e \"\\n\" >> #{FileName}"
#end
############################################

########### Parse scrape results ############
# require 'json'
# cols = ["domain", "company_name","mattermark_score", "custom_score","pre_money_valuation", "raised_amount", "employees",
#         "employees_month_ago", "employees_added_in_month", "est_founding_date", "stage", "total_funding",
#         "last_funding_date", "last_funding_amount", "location", "city", "region", "state", "country", "business_models",
#         "investors"];
# puts cols.join("\t");
# lines = File.readlines("mattermark_scrape_results.txt");
# lines.each do |line|
#   parsed_line = JSON.parse(line);
#   parsed_line["aaData"].each do |company_data|
#     values = cols.map{|col| ActionView::Base.full_sanitizer.sanitize(company_data[col].to_s)}
#     puts values.join("\t")
#   end
# end
################################################
############# parse linkedin contacts ############
require 'json'
cols = ["company_name", "linkedin_company_url", "contact_linkedin_url", "contact_first_name", "contact_last_name", "contact_headline"]
puts cols.join("\t");
lines = File.readlines("mattermark_linkedin_contacts.txt")
lines.each do |line|
  values = line.chomp().split("\t")
  if values.count() < 4
    next
  end
  parsed_line = JSON.parse(values[3])
  if parsed_line.blank?
    next
  end
  links = parsed_line.keys;
  links.each do |link|
    cols = []
    cols.append(values[2])
    cols.append("https://www.linkedin.com/company/#{values[1]}")
    cols.append(link)
    cols.append(parsed_line[link]["firstName"])
    cols.append(parsed_line[link]["lastName"])
    cols.append(parsed_line[link]["headline"])
    puts cols.join("\t")
  end
end
# begin
# require 'thread/pool'
# require 'uri'
# require 'nokogiri'
# require 'json'
# require 'HTMLEntities'
# require './OfflineScripts/JobScrappers/JobHelper.rb'
# include JobHelper
#
# Headers = {
#     "Referer" => "https://mattermark.com/app/data?operator[0]=stage%09!%3D%09Exited&operator[1]=interested%09!%3D%090&score_mobile_downloads=1&score_twitter_mentions=1",
#     "X-Requested-With" => "XMLHttpRequest",
#     "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36",
#     "Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8",
#     "Accept-Language" => "en-US,en;q=0.8",
#     "Cache-Control" => "no-cache",
#     "Cookie" => "__ar_v4=%7C3GKXIEUXWJAK5PMC2VVL7T%3A20140708%3A1%7CG3EIAJLTYVGBJNTJNZCIEZ%3A20140708%3A1%7CWI2NJ2OZKJELRIMUNEUNL5%3A20140708%3A1; session=ndrfkeblmh26q6jc5ffgu24852; ln=dc6d735bf32ab481853b71c4bc2b7c15df26578c%7EZoQcpFXrfyAGA1J1G7zmoB1qeZZrEbpL6JfmR7gbIUg%3D; _ga=GA1.2.1323943901.1404882479"
# }
#
# ThreadPoolLimit = 5
# ResultCountPerQuery = 50
#
# Uri = URI.join("http://mattermark.com", "/app/data/get/");
#
# Params = {"aoData[sEcho]"=>"1", "aoData[iColumns]"=>"44", "aoData[sColumns]"=>"", "aoData[iDisplayStart]"=>"0 ", "aoData[iDisplayLength]"=>"50", "aoData[mDataProp_0]"=>"company_name", "aoData[mDataProp_1]"=>"domain", "aoData[mDataProp_2]"=>"mattermark_score", "aoData[mDataProp_3]"=>"custom_score", "aoData[mDataProp_4]"=>"momentum_score", "aoData[mDataProp_5]"=>"is_raising", "aoData[mDataProp_6]"=>"raising_amount", "aoData[mDataProp_7]"=>"pre_money_valuation", "aoData[mDataProp_8]"=>"raised_amount", "aoData[mDataProp_9]"=>"employees", "aoData[mDataProp_10]"=>"employees_month_ago", "aoData[mDataProp_11]"=>"employees_added_in_month", "aoData[mDataProp_12]"=>"employees_mom", "aoData[mDataProp_13]"=>"cached_uniques", "aoData[mDataProp_14]"=>"cached_uniques_week_ago", "aoData[mDataProp_15]"=>"uniques_wow", "aoData[mDataProp_16]"=>"cached_uniques_month_ago", "aoData[mDataProp_17]"=>"uniques_mom", "aoData[mDataProp_18]"=>"cached_mobile_downloads", "aoData[mDataProp_19]"=>"cached_mobile_downloads_week_ago", "aoData[mDataProp_20]"=>"mobile_downloads_wow", "aoData[mDataProp_21]"=>"cached_mobile_downloads_month_ago", "aoData[mDataProp_22]"=>"mobile_downloads_mom", "aoData[mDataProp_23]"=>"cached_mobile_mattermark", "aoData[mDataProp_24]"=>"est_founding_date", "aoData[mDataProp_25]"=>"stage", "aoData[mDataProp_26]"=>"investors", "aoData[mDataProp_27]"=>"total_funding", "aoData[mDataProp_28]"=>"last_funding_date", "aoData[mDataProp_29]"=>"last_funding_amount", "aoData[mDataProp_30]"=>"location", "aoData[mDataProp_31]"=>"city", "aoData[mDataProp_32]"=>"region", "aoData[mDataProp_33]"=>"state", "aoData[mDataProp_34]"=>"country", "aoData[mDataProp_35]"=>"continent", "aoData[mDataProp_36]"=>"business_models", "aoData[mDataProp_37]"=>"industries", "aoData[mDataProp_38]"=>"keywords", "aoData[mDataProp_39]"=>"interested", "aoData[mDataProp_40]"=>"alert_hash", "aoData[mDataProp_41]"=>"user_tags", "aoData[mDataProp_42]"=>"keywords", "aoData[mDataProp_43]"=>"has_mobile", "aoData[sSearch]"=>"", "aoData[bRegex]"=>"false", "aoData[sSearch_0]"=>"", "aoData[bRegex_0]"=>"false", "aoData[bSearchable_0]"=>"true", "aoData[sSearch_1]"=>"", "aoData[bRegex_1]"=>"false", "aoData[bSearchable_1]"=>"true", "aoData[sSearch_2]"=>"", "aoData[bRegex_2]"=>"false", "aoData[bSearchable_2]"=>"true", "aoData[sSearch_3]"=>"", "aoData[bRegex_3]"=>"false", "aoData[bSearchable_3]"=>"true", "aoData[sSearch_4]"=>"", "aoData[bRegex_4]"=>"false", "aoData[bSearchable_4]"=>"true", "aoData[sSearch_5]"=>"", "aoData[bRegex_5]"=>"false", "aoData[bSearchable_5]"=>"true", "aoData[sSearch_6]"=>"", "aoData[bRegex_6]"=>"false", "aoData[bSearchable_6]"=>"true", "aoData[sSearch_7]"=>"", "aoData[bRegex_7]"=>"false", "aoData[bSearchable_7]"=>"true", "aoData[sSearch_8]"=>"", "aoData[bRegex_8]"=>"false", "aoData[bSearchable_8]"=>"true", "aoData[sSearch_9]"=>"", "aoData[bRegex_9]"=>"false", "aoData[bSearchable_9]"=>"true", "aoData[sSearch_10]"=>"", "aoData[bRegex_10]"=>"false", "aoData[bSearchable_10]"=>"true", "aoData[sSearch_11]"=>"", "aoData[bRegex_11]"=>"false", "aoData[bSearchable_11]"=>"true", "aoData[sSearch_12]"=>"", "aoData[bRegex_12]"=>"false", "aoData[bSearchable_12]"=>"true", "aoData[sSearch_13]"=>"", "aoData[bRegex_13]"=>"false", "aoData[bSearchable_13]"=>"true", "aoData[sSearch_14]"=>"", "aoData[bRegex_14]"=>"false", "aoData[bSearchable_14]"=>"true", "aoData[sSearch_15]"=>"", "aoData[bRegex_15]"=>"false", "aoData[bSearchable_15]"=>"true", "aoData[sSearch_16]"=>"", "aoData[bRegex_16]"=>"false", "aoData[bSearchable_16]"=>"true", "aoData[sSearch_17]"=>"", "aoData[bRegex_17]"=>"false", "aoData[bSearchable_17]"=>"true", "aoData[sSearch_18]"=>"", "aoData[bRegex_18]"=>"false", "aoData[bSearchable_18]"=>"true", "aoData[sSearch_19]"=>"", "aoData[bRegex_19]"=>"false", "aoData[bSearchable_19]"=>"true", "aoData[sSearch_20]"=>"", "aoData[bRegex_20]"=>"false", "aoData[bSearchable_20]"=>"true", "aoData[sSearch_21]"=>"", "aoData[bRegex_21]"=>"false", "aoData[bSearchable_21]"=>"true", "aoData[sSearch_22]"=>"", "aoData[bRegex_22]"=>"false", "aoData[bSearchable_22]"=>"true", "aoData[sSearch_23]"=>"", "aoData[bRegex_23]"=>"false", "aoData[bSearchable_23]"=>"true", "aoData[sSearch_24]"=>"", "aoData[bRegex_24]"=>"false", "aoData[bSearchable_24]"=>"true", "aoData[sSearch_25]"=>"", "aoData[bRegex_25]"=>"false", "aoData[bSearchable_25]"=>"true", "aoData[sSearch_26]"=>"", "aoData[bRegex_26]"=>"false", "aoData[bSearchable_26]"=>"true", "aoData[sSearch_27]"=>"", "aoData[bRegex_27]"=>"false", "aoData[bSearchable_27]"=>"true", "aoData[sSearch_28]"=>"", "aoData[bRegex_28]"=>"false", "aoData[bSearchable_28]"=>"true", "aoData[sSearch_29]"=>"", "aoData[bRegex_29]"=>"false", "aoData[bSearchable_29]"=>"true", "aoData[sSearch_30]"=>"", "aoData[bRegex_30]"=>"false", "aoData[bSearchable_30]"=>"true", "aoData[sSearch_31]"=>"", "aoData[bRegex_31]"=>"false", "aoData[bSearchable_31]"=>"true", "aoData[sSearch_32]"=>"", "aoData[bRegex_32]"=>"false", "aoData[bSearchable_32]"=>"true", "aoData[sSearch_33]"=>"", "aoData[bRegex_33]"=>"false", "aoData[bSearchable_33]"=>"true", "aoData[sSearch_34]"=>"", "aoData[bRegex_34]"=>"false", "aoData[bSearchable_34]"=>"true", "aoData[sSearch_35]"=>"", "aoData[bRegex_35]"=>"false", "aoData[bSearchable_35]"=>"true", "aoData[sSearch_36]"=>"", "aoData[bRegex_36]"=>"false", "aoData[bSearchable_36]"=>"true", "aoData[sSearch_37]"=>"", "aoData[bRegex_37]"=>"false", "aoData[bSearchable_37]"=>"true", "aoData[sSearch_38]"=>"", "aoData[bRegex_38]"=>"false", "aoData[bSearchable_38]"=>"true", "aoData[sSearch_39]"=>"", "aoData[bRegex_39]"=>"false", "aoData[bSearchable_39]"=>"true", "aoData[sSearch_40]"=>"", "aoData[bRegex_40]"=>"false", "aoData[bSearchable_40]"=>"true", "aoData[sSearch_41]"=>"", "aoData[bRegex_41]"=>"false", "aoData[bSearchable_41]"=>"true", "aoData[sSearch_42]"=>"", "aoData[bRegex_42]"=>"false", "aoData[bSearchable_42]"=>"true", "aoData[sSearch_43]"=>"", "aoData[bRegex_43]"=>"false", "aoData[bSearchable_43]"=>"true", "aoData[iSortCol_0]"=>"2", "aoData[sSortDir_0]"=>"desc", "aoData[iSortingCols]"=>"1", "aoData[bSortable_0]"=>"true", "aoData[bSortable_1]"=>"true", "aoData[bSortable_2]"=>"true", "aoData[bSortable_3]"=>"true", "aoData[bSortable_4]"=>"true", "aoData[bSortable_5]"=>"true", "aoData[bSortable_6]"=>"true", "aoData[bSortable_7]"=>"true", "aoData[bSortable_8]"=>"true", "aoData[bSortable_9]"=>"true", "aoData[bSortable_10]"=>"true", "aoData[bSortable_11]"=>"true", "aoData[bSortable_12]"=>"true", "aoData[bSortable_13]"=>"true", "aoData[bSortable_14]"=>"true", "aoData[bSortable_15]"=>"true", "aoData[bSortable_16]"=>"true", "aoData[bSortable_17]"=>"true", "aoData[bSortable_18]"=>"true", "aoData[bSortable_19]"=>"true", "aoData[bSortable_20]"=>"true", "aoData[bSortable_21]"=>"true", "aoData[bSortable_22]"=>"true", "aoData[bSortable_23]"=>"true", "aoData[bSortable_24]"=>"true", "aoData[bSortable_25]"=>"true", "aoData[bSortable_26]"=>"true", "aoData[bSortable_27]"=>"true", "aoData[bSortable_28]"=>"true", "aoData[bSortable_29]"=>"true", "aoData[bSortable_30]"=>"true", "aoData[bSortable_31]"=>"true", "aoData[bSortable_32]"=>"true", "aoData[bSortable_33]"=>"true", "aoData[bSortable_34]"=>"true", "aoData[bSortable_35]"=>"true", "aoData[bSortable_36]"=>"true", "aoData[bSortable_37]"=>"true", "aoData[bSortable_38]"=>"true", "aoData[bSortable_39]"=>"true", "aoData[bSortable_40]"=>"true", "aoData[bSortable_41]"=>"true", "aoData[bSortable_42]"=>"true", "aoData[bSortable_43]"=>"true", "aoData[sharing_key]"=>"", "treeQuery[boolean]"=>"AND", "treeQuery[members][0][field]"=>"stage", "treeQuery[members][0][operator]"=>"!", ""=>"treeQuery[members][0][value]", "Exited"=>"treeQuery[members][1][field]", "interested"=>"treeQuery[members][1][operator]", "!"=>"", "treeQuery[members][1][value]"=>"0", "es"=>"false", "customScoreWeights[web]"=>"0", "customScoreWeights[mobile_downloads]"=>"1", "customScoreWeights[twitter_mentions]"=>"1", "customScoreWeights[facebook_talking_count]"=>"0", "customScoreWeights[employees]"=>"0"};
#
# def get_companies(count)
#   STDERR.puts "starting thread with #{count}"
#   uri = Uri.clone();
#   STDERR.puts "uri #{uri}"
#   params_local = Params.clone();
#   params_local["aoData[iDisplayStart]"] = "#{count}";
#   STDERR.puts "params #{params_local}"
#   STDERR.puts "making request"
#   response = makeHttpRequest(uri, Headers, nil, params_local, 0, nil)
#
#   STDERR.puts "finished getting response"
#   if response == nil
#     STDERR.puts "Response nil"
#   end
#
#   puts response.body
#   sleep(5)
# end
#
# #resultCount = 228354
# resultCount = 50
# STDERR.puts "Total Result Count is #{resultCount}"
# pool = Thread.pool(ThreadPoolLimit);
# start_counts = (0..resultCount).step(ResultCountPerQuery).to_a
# start_counts.each do |count|
#   STDERR.puts "Starting thread with count = #{count}"
#   pool.process{get_companies(count)}
# end
# # waiting for threads to exit
# pool.shutdown;=end
