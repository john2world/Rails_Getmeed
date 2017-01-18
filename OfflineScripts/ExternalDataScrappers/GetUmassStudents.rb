SearchUrl = 'http://www.umass.edu/peoplefinder/engine/'
Headers = {
    "Accept"=>"application/json, text/javascript, */*; q=0.01",
    "Accept-Encoding"=>"gzip, deflate",
    "Accept-Language"=>"en-US,en;q=0.8",
    "Connection"=>"keep-alive",
    "Content-Length"=>"38",
    "Content-Type"=>"application/x-www-form-urlencoded",
    "Cookie"=>"__utma=198765611.1450978750.1443554078.1443554078.1443554078.1; __utmc=198765611; __utmz=198765611.1443554078.1.1.utmcsr=google|utmccn=(organic)|utmcmd=organic|utmctr=(not%20provided); _ga=GA1.2.1450978750.1443554078; has_js=1",
    "Host"=>"www.umass.edu",
    "Origin"=>"http://www.umass.edu",
    "Referer"=>"http://www.umass.edu/peoplefinder/",
    "User-Agent"=>"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36",
    "X-Requested-With"=>"XMLHttpRequest",
}

DegreeMapping = {
    "BA"=>"Bachelor of Arts",
    "PhD"=>"PhD",
    "MS"=>"Master of Science",
    "BS"=>"Bachelor of Science",
    "Graduate School"=>"",
    "Non Credit"=>"",
    "Non Deg"=>"",
    "BBA"=>"Bachelor of Business Administration",
    "MEd"=>"Master of Education",
    "MSCE"=>"Master of Science in Civil Engineering",
    "BMus"=>"Bachelor of Music",
    "MSECE"=>"Master of Science in Electrial and Computer Engineering",
    "M.Arch"=>"Master of Architecture",
    "MA"=>"Master of Arts",
    "MPH"=>"Master of Public Health",
    "EdD"=>"Doctor of Education",
    "NonDeg"=>"",
    "BFA"=>"Bachelor of Fine Arts",
    "MLA"=>"Master of Liberal Arts",
    "MSIEOR"=>"Master of Science in Industrial Engineering and Operations Research",
    "MM"=>"Master of Music",
    "DNP"=>"Doctor of Nursing Practise",
    "MSEM"=>"Mathematics Sheltered English Project",
    "MFA"=>"Master of Fine Arts",
    "MBA"=>"Master of Business Administration",
    "AS"=>"Associate of Science",
    "AuD"=>"Doctor of Audiology",
    "EdS"=>"Educational Specialist",
    "BGS"=>"Bachelor of General Studies",
    "Undergraduate"=>"Bachelor",
    "MPPA"=>"Master of Public Policy Administration",
    "MRP"=>"Master of Regional Planning",
    "Non Degree"=>"",
    "MPP"=>"Master of Public Policy",
    "MAT"=>"Master of Arts in Teaching",
    "MSCHE"=>"Master of Science in Chemical Engineering"
}

def search(name)
  search_form = {"q" => name, "time" => Time.now.to_i, "aff" => 'student'}
  response = HTTParty.post(SearchUrl, :headers => Headers, :body => search_form)
  begin
    data = JSON.parse(response.body)
  rescue
    return {}
  end
  # convert to hash
  return Hash[data["Results"].map{|r| [r["Email"], r]}]
end

all_results = {};
first_names = User.where(:first_name.ne => nil).pluck(:first_name).map{|name| name.split(' ')[0].downcase()}.uniq;
first_names.each do |name|
  puts "#{name}"
  results = search(name);
  all_results = results.merge(all_results);
end

# filtering candidates who doesn't have a major
all_results = all_results.select{|key, value| !value["Major"].blank?};

f = File.open('./OfflineScripts/JobScrappers/umass_students.csv', "w")

all_results.each do |key, value|
  major = nil
  dept = nil
  unless value['Major'].blank?
    major = value['Major'].join(',')
  end
  unless value['Dept'].blank?
    dept = value['Dept'].join(',')
  end
  degree = nil
  unless value['Major'].blank?
    value['Major'].each do |major|
      matches = major.match(/.* \((.*)\)$/)
      if !matches.blank? and matches.captures.count() > 0
        degree = DegreeMapping[matches[1]]
      end
    end
  end
  major = major.gsub(/\s\(.+\)$/, '')
  f.puts "#{value['Name']},#{value['Email']}, #{major}, #{degree}, #{dept}"
end
f.close()


################ START OF CODE FOR MANUAL SCRAPPING #############

students = []

def get_student_details_from_node(node)
  name_node = node.at_xpath(".//div[contains(@class, 'field-name-title')]")
  link_node = node.at_xpath(".//div[contains(@class, 'field-name-field-link')]//div[@class='field-items']")
  email_node = node.at_xpath(".//div[contains(@class, 'field-name-field-email')]//div[@class='field-items']")
  research_node = node.at_xpath(".//div[contains(@class, 'field-name-field-research')]//div[@class='field-items']")
  job_node = node.at_xpath(".//div[contains(@class, 'field-name-field-accepted-job')]//div[@class='field-items']")
  advisor_node = node.at_xpath(".//div[contains(@class, 'field-name-field-advisor')]//div[@class='field-items']")
  graduation_node = node.at_xpath(".//div[contains(@class, 'field-name-field-graduation-date')]//div[@class='field-items']")
  student_data = {}
  unless name_node.blank?
    student_data[:name] = name_node.inner_text
  end
  unless link_node.blank?
    student_data[:link] = link_node.inner_text
  end
  unless email_node.blank?
    student_data[:email] = email_node.inner_text
  end
  unless research_node.blank?
    student_data[:research] = research_node.inner_text
  end
  unless job_node.blank?
    student_data[:job] = job_node.inner_text
  end
  unless advisor_node.blank?
    student_data[:advisor] = advisor_node.inner_text
  end
  unless graduation_node.blank?
    student_data[:graduation] = graduation_node.inner_text
  end
  return student_data
end

f = File.open(filename);
json = JSON.parse(f.read());
f.close();
doc = Nokogiri::HTML(json[2]["data"]);
student_nodes = doc.xpath(".//div[contains(@class, 'node-student')]");
students.concat(student_nodes.map{|node| get_student_details_from_node(node)});
