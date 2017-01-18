module HttpPartyManager
  def post (url, body_json)
    HTTParty.post(url,
                  :body => body_json,
                  :headers => {'Content-Type' => 'application/json', 'User-Agent' => 'resu.me'})
  end


end