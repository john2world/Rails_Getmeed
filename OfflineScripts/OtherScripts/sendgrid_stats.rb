headers = {"Connection"=>"keep-alive",
           "Cache-Control"=>"max-age=0",
           "Accept"=>"application/json, text/javascript, */*; q=0.01",
           "x-sg-elas-acl"=>"honeybadgered",
           "Origin"=>"https://app.sendgrid.com",
           "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.85 Safari/537.36",
           "Authorization"=>"token 0e51ad60092b641479b7d339aa21925b",
           "Referer"=>"https://app.sendgrid.com/email_activity?page=24",
           "Accept-Encoding"=>"gzip, deflate, sdch",
           "Accept-Language"=>"en-US,en;q=0.8"}

TimeZoneOffset = {
    "illinois" => 2,
    'rice' => 3,
    'usc' => 0,
    'cornell' => 1,
    'ucla' => 0,
    'duke' => 0,
    'nyu' => 3,
    'berkeley' => 0,
    'cmu' => 3,
    'gatech' => 3,
    'ucsd' => 0,
    'uci' => 0,
    'stanford' => 0,
    'brown' => 3,
    'mit' => 3,
    'utexas' => 2,
    'washington' => 0,
    'northwestern' => 2,
    'upenn' => 3,
    'umich' => 3,
    'princeton' => 3,
    'columbusstate' => 3,
    'umass' => 3,
    'ufl' => 3
}

limit = 500
offset = 0
data = []
(0..9).each do |i|
  offset = i*limit
  url = "https://api.sendgrid.com/v3/email_activity?limit=#{limit}&offset=#{offset}"
  response = HTTParty.get(url, :headers => headers);
  data = data + JSON.parse(response.body);
end

open_events = data.select{|data| data["event"] == "open"}.select{|data| data["email"].include? ".edu"}
# map open events to hours

hours_histogram = open_events.map{|event| [get_school_handle_from_email(event["email"]), Time.at(event["created"]).hour]};
hours_histogram = hours_histogram.map{|p| [p[0], p[1], TimeZoneOffset[p[0]] ]}.select{|p| !p[2].blank?};
hours_histogram.map{|p| (p[1]+p[2])%24}.group_by{|hour| hour}.map{|key,value| [key, value.count()]}.sort_by{|pair| pair[0]}.each{|p| puts "#{p[0]}\t#{p[1]}"};