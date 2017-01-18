require 'net/http'
require "net/https"
require 'uri'
require 'cgi/cookie'
require './OfflineScripts/lib/utils.rb'
include Util

module Proxy
  ProxyUrls = [
       "http://012ooo.proxyserver.asia/browse.php?u=",
       "http://1proxy.xyz/b.php?u=",
       "http://1stproxy.club/browse.php?u=",
       "http://2proxy.xyz/b.php?u=",
       "http://4proxy.xyz/b.php?u=",
       "http://aproxy.info/browse.php?u=",
       "http://bbproxy.pw/b.php?u=",
       "http://bluebbs.ga/browse.php?u=",
       "http://c1.yunproxy.org/b.php?u=",
       "http://caproxy.pw/b.php?u=",
       "http://ccproxy.pw/b.php?u=",
       "http://center.proxysan.info/b.php?u=",
       "http://champion.proxyserver.asia/browse.php?u=",
       "http://deproxy.pw/b.php?u=",
       "http://easyhideip.org/browse.php?u=",
       "http://free-proxysite.com/browse.php?u=",
       "http://freeproxy.club/browse.php?u=",
       "http://freewebproxy.xyz/Loan.php?u=",
       "http://frproxy.pw/b.php?u=",
       "http://gbproxy.pw/b.php?u=",
       "http://iiproxy.pw/b.php?u=",
       "http://iproxysite.com/browse.php?u=",
       "http://krproxy.pw/b.php?u=",
       "http://llproxy.pw/b.php?u=",
       "http://mainprox.com/browse.php?u=",
       "http://mmproxy.pw/b.php?u=",
       "http://new.2r34.com/b.php?u=",
       "http://ninjaproxy.in/browse.php?u=",
       "http://onlineproxy.xyz/Loan.php?u=",
       "http://proxy.hidesurf.asia/b.php?u=",
       "http://proxygogo.info/b.php?u=",
       "http://proxysan.info/b.php?u=",
       "http://rexoss.com/browse.php?u=",
       "http://ssl.proxygogo.info/b.php?u=",
       "http://us.newproxy.pw/b.php?u=",
       "http://us.proxygogo.info/b.php?u=",
       "http://us.proxyguru.info/b.php?u=",
       "http://usc.proxygogo.info/b.php?u=",
       "http://usc.proxyhash.info/b.php?u=",
       "http://usproxy.pw/b.php?u=",
       "http://vtunnelproxy.club/browse.php?u=",
       "http://web.newproxy.pw/b.php?u=",
       "http://web.proxysan.info/b.php?u=",
       "http://web.securesurf.pw/b.php?u=",
       "http://www.52ufo.org/b.php?u=",
       "http://www.aaproxy.pw/b.php?u=",
       "http://www.bluebbs.ga/browse.php?u=",
       "http://www.callfast.ga/browse.php?u=",
       "http://www.centralproxy.ga/browse.php?u=",
       "http://www.cheapproxy.cf/browse.php?u=",
       "http://www.cheapproxy.ga/browse.php?u=",
       "http://www.colorproxy.gq/index.php?q=",
       "http://www.computerinfo.ga/browse.php?u=",
       "http://www.enterproxy.ga/browse.php?u=",
       "http://www.expatproxy.com/browse.php?u=",
       "http://www.extraproxy.com/browse.php?u=",
       "http://www.fineproxy.cf/browse.php?u=",
       "http://www.freesslproxy.biz/browse.php?u=",
       "http://www.heyproxy.com/browse.php?u=",
       "http://www.highjob.ml/browse.php?u=",
       "http://www.kideng.ml/browse.php?u=",
       "http://www.localmodel.cf/browse.php?u=",
       "http://www.morecomputer.ml/browse.php?u=",
       "http://www.myincome.cf/browse.php?u=",
       "http://www.playproxy.cf/browse.php?u=",
       "http://www.proxy4freedom.cf/browse.php?u=",
       "http://www.proxybitcoin.com/browse.php?u=",
       "http://www.proxygrade.ml/browse.php?u=",
       "http://www.proxyok.com/browse.php?u=",
       "http://www.proxyspark.com/index.php?q=",
       "http://www.proxystreaming.com/browse.php?u=",
       "http://www.qqproxy.pw/b.php?u=",
       "http://www.sportneed.ml/browse.php?u=",
       "http://www.surfproxy.cf/browse.php?u=",
       "https://mablet.com/browse.php?u=",
       "http://fast-proxy-server.org/index.php?q=",
       "https://www.websurf.in/browse.php?u=",
       "http://ninjaproxy.in/browse.php?u=",
       "http://new.2r34.com/b.php?u=",
       "http://www.aaproxy.pw/b.php?u=",
       "http://mmproxy.pw/b.php?u=",
       "http://www.qqproxy.pw/b.php?u=",
       "http://www.proxybitcoin.com/browse.php?u=",
       "http://iiproxy.pw/b.php?u=",
       "http://proxyserver.ovh/browse.php?u=",
       "http://www.proxystreaming.com/browse.php?u=",
       "http://ccproxy.pw/b.php?u=",
       "http://www.phproxy.me/index.php?q=",
       "http://bbproxy.pw/b.php?u=",
       "http://1proxy.xyz/b.php?u=",
       "http://www.tiiner.com/browse.php?u=",
      "http://www.simpleproxy.info/browse.php?u=",
      "http://www.twoproxy.com/browse.php?u=",
      "http://www.seezin.com/browse.php?u=",
      "http://www.freewebproxy.us/browse.php?u=",
      "http://www.ioxy.de/browse.php?u=",
      "http://fast.webproxy.yt/index.php?q=",
      "http://www.koxy.de/browse.php?u=",
      "http://proxy.wiksa.com/browse.php?u=",
      "http://www.surfma.nu/index.php?q=",
      "http://fardoex.nu/index.php?q=",
      "http://frochti.nu/index.php?q=",
      "http://www.rnproxy.com/index.php?q=",
      "http://www.007unblocker.com/browse.php?u=",
      "http://www.proxyfounder.com/browse.php?u=",
      "http://www.wxproxy.com/index.php?q=",
      "http://chistir.nu/index.php?q=",
      "http://bcorx.nu/index.php?q=",
      "http://abastex.nu/index.php?q=",
      "http://chatabe.nu/index.php?q=",
      "http://p-4p.com/index.php?q=",
      "http://freeproxyforxe.com/index.php?q=",
      "http://new-free-proxy.com/index.php?q=",
      "http://4-freeproxyserver.com/index.php?q=",
      "http://www.freeproxyrox.com/index.php?q=",
      "http://freeproxyforxe.com/index.php?q=",
      "http://4-freeproxyserver.com/index.php?q=",
      "http://frochti.nu/index.php?q=",
      "http://www.freeproxyrox.com/index.php?q=",
      "http://www.rapid-proxy.net/index.php?q=",
      "http://www.proxyful.com/index.php?q=",
      "http://pourproxy.com/index.php?q=",
      "http://www.puzzle-proxy.com/index.php?q=",
      "http://euproxy.pw/b.php?u=",
      "http://yyproxy.pw/b.php?u=",
      "http://single.ovh/browse.php?u=",
      "http://xxproxy.pw/b.php?u=",
      "http://freeproxy.rocks/browse.php?u=",
      "http://www.webproxy.tn/browse.php?u=",
      "http://5proxy.xyz/b.php?u=",
      "http://1proxy.rocks/browse.php?u=",
      "http://alittle.rocks/browse.php?u=",
      "http://www.url10.org/browse.php?u=",
      "http://france.proxy8.asia/b.php?u=",
      "http://protoxy.info/index.php?q=",
      "http://iproxyserver.info/index.php?q=",
      "http://gamypro.info/index.php?q=",
      "http://tinyproxy.info/index.php?q=",
      "http://www.your-proxy.com/Index.php?q=",
      "http://www.your-proxy.com/Index.php?q=",
      "http://www.rapid-proxy.net/index.php?q=",
      "http://www.weblost.gq/index.php?q=",
      "http://www.soloproxy.gq/index.php?q=",
      "http://www.freeproxy10.ga/index.php?q=",
      "http://www.fastproxyservices.com/index.php?q=",
      "http://www.usproxy.website/index.php?q=",
      "http://www.ghostproxy.nl/browse.php?u=",
      "http://1big.rocks/browse.php?u=",
      "https://1freeproxyserver.com/browse.php?u=",
      "http://abcproxy.gq/browse.php?u=",
      "http://freeproxyserver.ovh/browse.php?u=",
      "http://abc.a-tunnel.info/browse.php?u=",
      "http://www.dutchproxyland.com/browse.php?u=",
      "http://www.freedutchproxy.nl/browse.php?u="
  ]
  ProxyUrlsSIZE = ProxyUrls.count()
  Headers = {
      "Proxy-Connection" => "keep-alive",
      "Cache-Control" => "max-age=0",
      "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
      "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.149 Safari/537.36",
      "Accept-Language" => "en-US,en;q=0.8"
  }
  ProxyCookies = {}

  def getProxyCookies(proxy_url, qps)
    # make dummy request to proxy_url and then store the cookie
    headers = Headers.clone()
    response = makeHttpRequest(URI(proxy_url), headers, nil, nil, qps, nil)
    unless response['set-cookie'].blank?
      ProxyCookies[proxy_url] = response['set-cookie']
      return
    end
    unless headers['Cookie'].blank?
      ProxyCookies[proxy_url] = headers['Cookie']
      return
    end
  end

  def makeHttpProxyRequest(uri, headers=nil, urlParameters=nil, formParameters=nil, qps=0, ignoreRedirectUrl = nil, proxy_index = nil)
    if proxy_index.blank?
      proxy_index = rand(0..ProxyUrlsSIZE)
    end
    proxy_url = ProxyUrls[proxy_index]

    if urlParameters != nil
      uri.query = URI.encode_www_form( urlParameters )
    end
    # escape the complete url and as a url parameter to proxy url
    final_url = URI(proxy_url+Rack::Utils.escape(uri.to_s))
    # if we dont have cookies for this proxy get one
    unless ProxyCookies.has_key? proxy_url
      getProxyCookies(proxy_url, qps)
    end
    unless ProxyCookies[proxy_url].blank?
      headers['Cookie'] = ProxyCookies[proxy_url]
    end
    return makeHttpRequest(final_url, headers, nil, nil, qps, ignoreRedirectUrl), proxy_url
  end
end