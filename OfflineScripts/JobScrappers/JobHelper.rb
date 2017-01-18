require 'net/http'
require "net/https"
require 'uri'
require 'cgi/cookie'

include JobsManager

module JobHelper  
  ################################################################################################################################
  ########################################################## Constants ###########################################################
  ################################################################################################################################
  Schools = [
  	"brown",
  	"caltech",
  	"cmu",
  	"columbia",
  	"cornell",
  	"duke",
  	"gatech",
  	"harvard",
  	"mit",
  	"nyu",
  	"northwestern",
  	"princeton",
  	"rice",
  	"stanford",
  	"berkeley",
  	"ucla",
  	"ufl",
  	"illinois",
  	"usc"
  ]

  MaxRetryLimit = 3
  NetworkTimeOut = 15

  Description_lb_after = Regexp.new('(\<br\s*\/?\>|\<\/h\d\>|\\n)(\<br\s*\/?\>|\\n)+')
  Description_lb_before = Regexp.new('(\<br\s*\/?\>|\\n)(\<h\d\>)')
  Intern_title = Regexp.new('(^|\s)intern(ship(s)?)?(\s|$)', Regexp::IGNORECASE)
  ################################################################################################################################

  ################################################################################################################################
  ####################################################### Helper Functions #######################################################
  ################################################################################################################################
  
  def sanitizeDescription(description)
    # processing the description to look beautiful
    # removing any unnessary line breaks after selected tags
    description = description.gsub(Description_lb_after, "\\1")
    #removing any unnessary line breaks before selected tags
    description = description.gsub(Description_lb_before, "\\2")
    description = HTMLEntities.new.decode(description)
    # decoding double encoding
    description = HTMLEntities.new.decode(description)
    return description
  end

  def sanitize_text(text)
    text = text.gsub(/[\t\n]/, '')
    text = text.gsub(/\s+/, ' ')
    text = text.strip()
  end

  def save_job_extra(job_hash, majors)
  
    # first check if the entry already exists based on external_id and source
    if job_hash.has_key?(:id) && job_hash.has_key?(:source)
      # check if the Jobs model contains the entry with same external_id and same source
      if Job.find_by(external_id:job_hash[:id], source:job_hash[:source]) != nil
        # a job already exists with same id and same source hence not saving it
        return
      end
    end
  
    # first saving the job using the default method
    job = JobsManager.save_job(job_hash, Schools, majors);

    # adding additional parameters to the job not saved by default
    job[:source] = job_hash[:source]
    job[:external_id] = job_hash[:id]
    job[:post_date] = job_hash[:post_date]

    # finally saving the job 
    job.save;
  end

  def makeHttpRequest(url, headers=nil, urlParameters=nil, formParameters=nil, qps=0, ignoreRedirectUrl = nil)
    # Throttling traffic by making the thread sleep
    if (qps > 0)
      sleep(1.0/qps);
    end
    post = true
    if formParameters == nil
      post = false
    end

    if urlParameters != nil
      url.query = URI.encode_www_form( urlParameters )
    end

    http = Net::HTTP.new(url.host, url.port)
    http.open_timeout = NetworkTimeOut
    http.read_timeout = NetworkTimeOut

    if url.to_s.starts_with?("https")
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    if post
      req = Net::HTTP::Post.new(url, headers)
      req.set_form_data(formParameters)
    else
      req = Net::HTTP::Get.new(url, headers)
    end

    # retry in case of failure
    count = 0
    response = nil
    begin
      begin
        response = http.request(req)
        if (ignoreRedirectUrl != nil && response.code.starts_with?("3") && response['location'].contains(ignoreRedirectUrl))
          $stderr.puts "ignoring Redirect Url. Redirect Url = #{response['location']}"
          raise Exception
        end
      rescue
        $stderr.puts "encountered error getting url #{url} retrying for #{count} time ..."
      end
      # in case of an exception just increment the counter
      count += 1
    end while ((response == nil) || 
              (response.code.starts_with?("4") || response.code.starts_with?("5"))) && (count < MaxRetryLimit)
  
    # if response is a redirection follow the redirection
    if response != nil && response.code.starts_with?("3")
      $stderr.puts "Found a redirection to #{response['location']} following it. Base Url: #{url}"
      return makeHttpRequest(URI.parse(response['location']), headers, nil, formParameters)
    else
      return response
    end
  end

  def get_job_type(title)
    if(Intern_title.match(title))
      return "intern"
    else
      return "full_time_entry_level"
    end
  end
  ################################################################################################################################
end

module HTTPResponseDecodeContentOverride
  def initialize(h,c,m)
    super(h,c,m)
    @decode_content = true
  end
  def body
    res = super
    if self['content-length']
      self['content-length']= res.bytesize
    end
    res
  end
end
module Net
  class HTTPResponse
    prepend HTTPResponseDecodeContentOverride
  end
end