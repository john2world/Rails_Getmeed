require 'thread'


URLFormat = "https://api.import.io/store/data/85c7fef8-6226-416c-9947-b6a519e9870b/_query?input/webpage/url=%s&_user=19e2e2d9-8ac0-4f13-a280-a149b5f9f332&_apikey=19e2e2d98ac04f13a280a149b5f9f332637cd8693e91cd35ff5f1652874dae2fc82efd2856d16a1e3ff102908175079e49caa69004be4aff16a4eb5d68248f65d37e07e8fc4ddddec2f22a84a091b443"
SchoolSearchUrlFormat = "http://www.bu.edu/phpbin/directory/?q=%s"
filename="/Users/ViswaMani/Desktop/first_names.txt"
#filename = "/Users/ViswaMani/Downloads/school_scrapes/leftover.txt"
values = File.open(filename).readlines();
# for each school get upto 250 users so pagination = 5
school_urls = values.map{|value| sprintf(SchoolSearchUrlFormat, CGI::escape(value))}
urls = school_urls.map{|value| sprintf(URLFormat,  CGI::escape(value))};
$stderr.puts "Scrapping #{urls.count()} urls"
#output_file = filename + ".out"
output_file = "/Users/ViswaMani/Downloads/school_scrapes/boston_search_results.txt"
fileout = File.open(output_file, "w")
start_time = Time.now()
retry_urls = []
workers = (0..10).map do
  Thread.new do
    while url = urls.shift()
      begin
        retry_limit = 3
        while retry_limit > 0
          response = HTTParty.get(url)
          unless response.body.blank?
            fileout.puts response.body
            break
          end
        end
        if response.blank? or response.code.to_i != 200
          # sleep for a couple of seconds and add url to retry
          #retry_urls.push(url)
          #sleep 5
          $stderr.puts "got #{response.code.to_i} code"
          $stderr.puts "url: #{url}"
        end
      rescue Exception => ex
        #sleep 5
        $stderr.puts ex
        $stderr.puts url
      end
    end
  end
end; "ok"
workers.map(&:join); "ok"

$stderr.puts "Took: #{(Time.now() - start_time).seconds}"
