require './OfflineScripts/JobScrappers/JobHelper.rb'
include JobHelper
require 'nokogiri'
include UsersHelper
profiles = Profile.pluck(:handle).uniq();
user_profiles = User.pluck(:handle).uniq();
user_lost_profiles = UserLost.pluck(:handle).uniq();
diff_profiles = profiles - user_profiles - user_lost_profiles;

$headers = {
    "Proxy-Connection" => "keep-alive",
    "Cache-Control" => "max-age=0",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
    "Accept-Language" => "en-US,en;q=0.8"
}

def create_user(handle)
  unless (Algolia_results_hash.has_key? handle) && (Invitations_with_emails_hash.has_key? handle)
    return
  end
  email = Invitations_with_emails_hash[handle][:email]
  user = UserLost.new(:email => email)
  user[:handle] = handle
  name = Algolia_results_hash[handle]["name"]
  words = name.split(" ")
  last_name = words.pop()
  first_name = words.join(" ")
  user[:email] = email
  user[:last_name] = last_name
  user[:first_name] = first_name
  user[:primary_email] = email
  user[:degree] = Algolia_results_hash[handle]["degree"]
  major = Major.find_by(major: Algolia_results_hash[handle]["major"])
  user[:major] = Algolia_results_hash[handle]["major"]
  unless major.blank?
    user[:major_id] = major[:code]
  end
  profile = Profile.find(handle)
  unless profile.blank?
    user[:create_dttm] = profile[:last_update_dttm]
  end
  user.save()
end

def create_user_from_cache(handle)
  unless (Cache_hash.has_key? handle) && (Invitations_with_emails_hash.has_key? handle)
    return
  end
  email = Invitations_with_emails_hash[handle][:email]
  user = UserLost.new(:email => email)
  user[:handle] = handle
  name = Cache_hash[handle][:name]
  words = name.split(" ")
  last_name = words.pop()
  first_name = words.join(" ")
  user[:email] = email
  user[:last_name] = last_name
  user[:first_name] = first_name
  user[:primary_email] = email
  user[:degree] = Cache_hash[handle][:degree]
  major = Major.find_by(major: Cache_hash[handle][:major])
  user[:major] = Cache_hash[handle][:major]
  unless major.blank?
    user[:major_id] = major[:code]
  end
  profile = Profile.find(handle)
  unless profile.blank?
    user[:create_dttm] = profile[:last_update_dttm]
  end
  user[:year] = Cache_hash[handle][:year]
  user[:gpa] = Cache_hash[handle][:gpa]
  user.save()

end

def update_user_from_cache(obj)
  user = UserLost.find_by(handle: obj[:handle])
  if user.blank?
    return
  end
  user[:year] = obj[:year]
  user[:gpa] = obj[:gpa]
  user.save()
end

def create_user_from_scrape(handle)
  unless (Invitations_with_emails_hash.has_key? handle)
    return
  end
  inv = Invitations_with_emails_hash[handle]
  scrape = SchoolMap[inv[:email]]
  if scrape.blank?
    return
  end
  user = UserLost.new(:email => scrape[:email])
  user[:handle] = handle
  name = scrape[:name]
  words = name.split(" ")
  last_name = words.pop()
  first_name = words.join(" ")
  user[:last_name] = last_name
  user[:first_name] = first_name
  user[:primary_email] = email
  user[:major_id] = scrape[:major]
  major = Major.find(scrape[:major])
  unless major.blank?
    user[:major] = major[:major]
  end
  profile = Profile.find_by(handle: handle)
  unless profile.blank?
    user[:create_dttm] = profile[:last_update_dttm]
  end
  user.save()
end

def create_user_manually(scrape)
  email = scrape[:inv][2]["email"]
  handle = scrape[:inv][0]
  name = scrape[:name]
  user = UserLost.new(:email => email)
  user[:handle] = handle
  words = name.split(" ")
  last_name = words.pop()
  first_name = words.join(" ")
  user[:last_name] = last_name
  user[:first_name] = first_name
  user[:primary_email] = email
  profile = Profile.find_by(handle: handle)
  unless profile.blank?
    user[:create_dttm] = profile[:last_update_dttm]
  end
  user.save()
end
# get latest time stamp of active user
last_time = Time.utc(2015, 12, 03)

# get email invitations from that time
invitations = EmailInvitation.where(activated: true);

# get map of handles
invitation_map = invitations.map{|inv| [get_handle_from_email(inv[:email]).gsub("-","."), inv]};
invitations_with_emails = invitation_map.select{|inv| diff_profiles.include? inv[0]};
# grouping
Invitations_with_emails_hash = Hash[invitations_with_emails];
missing_invitations = diff_profiles - invitations_with_emails_hash.map{|inv| inv[1]};

# get from algolia
index = Algolia::Index.new("Search");
algolia_results = diff_profiles.map{|profile| r = index.search(profile, {restrictSearchableAttributes: "handle"}); (r["nbHits"] > 0 && r["hits"][0]["handle"] == profile) ? r["hits"][0] : nil};
Algolia_results_hash = Hash[algolia_results.compact().map{|r|[r["handle"].gsub(".", "-"),r]}];

common_keys = Invitations_with_emails_hash.keys & Algolia_results_hash.keys;
# get from intercom
intercom_users = []
diff_profiles.each do |profile|
  begin
    user = IntercomClient.users.find(:user_id => profile)
    intercom_users.push(user)
  rescue Exception
  end
end

objs = diff_profiles.map{|profile| get_details_from_cache(profile)}
Cache_hash = Hash[objs.group_by{|obj|obj[:handle]}.map{|k,v| [k,v[0]]}]

leftovers = invitations_with_emails.map{|inv| [get_handle_from_email(inv[1]["email"]), get_school_handle_from_email(inv[1]["email"]), inv[1]]};

def get_details_from_cache(profile)
  url = URI.join("http://webcache.googleusercontent.com","/search")
  params = { :q => "cache:https://getmeed.com/"+profile }
  response = makeHttpRequest(url, $headers, params, nil, 0)
  doc = Nokogiri::HTML(response.body)
  node = doc.xpath("//table[contains(@class, 'details-row') and contains(@class, 'product')]")
  table = doc.xpath("//table[@id='show_single_header_false']")
  if table.blank? || table.count() == 0
    return
  end
  table = table[0]
  name = sanitize_text(table.xpath("//tr[1]/td[1]").inner_text)
  major = sanitize_text(table.xpath("//tr[2]/td[1]").inner_text)
  degree = sanitize_text(table.xpath("//tr[3]/td[1]").inner_text)
  university_node = sanitize_text(table.xpath("//tr[4]/td[1]").inner_text).split(" — ")
  university = university_node[0]
  year = university_node[1]
  gpa = sanitize_text(table.xpath("//tr[4]/td[2]").inner_text).split(" — ")[1]
  return {
      :handle => profile,
      :name => name,
      :major => major,
      :degree => degree,
      :university => university,
      :year => year,
      :gpa => gpa
  }
end