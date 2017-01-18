# Utils module having utility function
require 'net/http'
require "net/https"
require 'uri'
require 'cgi/cookie'
module Util
  MaxRetryLimit = 3
  NetworkTimeOut = 15
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
      # copying the cookies
      unless response['set-cookie'].blank?
        headers['Cookie'] = response['set-cookie']
      end
      return makeHttpRequest(URI.parse(response['location']), headers, nil, formParameters)
    else
      return response
    end
  end
  def sanitize_text(text)
    if text.blank?
      return
    end
    text = text.gsub(/[\t\n]/, '')
    text = text.gsub(/\s+/, ' ')
    text = text.strip()
  end
end