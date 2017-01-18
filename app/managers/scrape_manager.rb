module ScrapeManager
  include FeedItemsManager
  include PhotoManager
  include PhotoHelper
  include JobsHelper

  def get_scrape_by_id(id)
    ScrapeData.find(id)
  end

  def get_scrape_by_title(title)
    ScrapeData.where(:title => title).first
  end

  def scrape_and_create_article(scrape_data)
    if scrape_data.blank?
      return nil
    end
    embedly_api =
        Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@resu.me)'
    obj = embedly_api.extract :url => scrape_data.url

    if obj.blank?
      return nil
    end

    json_hash = obj[0].marshal_dump
    if json_hash.blank?
      return nil
    end

    article = Article.new
    article.id = scrape_data.id
    article.source = json_hash[:provider_name]
    article.description = json_hash[:description]
    article.title = json_hash[:title]
    unless json_hash[:authors].blank? or json_hash[:authors][0].blank?
      article.author = json_hash[:authors][0][:name]
      article.author_url = json_hash[:authors][0][:url]
    end
    unless json_hash[:images].blank? and json_hash[:images][0].blank?
      photo = upload_photo(json_hash[:images][0][:url.to_s], json_hash[:images][0][:width.to_s],
                           json_hash[:images][0][:height.to_s], scrape_data.id, scrape_data.type)
      unless photo.blank?
        article.photo_id = photo.id
      end

    end
    unless scrape_data.company_id.blank?
      article.company_id = scrape_data.company_id
    end
    unless scrape_data.type.blank?
      article.type = scrape_data.type
    end
    if scrape_data.type.eql? 'video'
      article.video_id = scrape_data.video_id
    end
    article.external_url = json_hash[:original_url]
    unless json_hash[:content].blank?
      if json_hash[:type].eql? 'html'
        html_content = Sanitize.fragment(json_hash[:content],
                                         :elements => %w(a span p h1 h2 h3 h4 ul li div),
                                         :attributes => {
                                             :a.to_s => %w(href title)
                                         })
        article.html = html_content
      end
    end
    article.save
    article
  end

  def rescrape_data(scrape_data)
    if scrape_data.blank?
      return
    end

    begin
      embedly_api =
          Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@resu.me)'
      obj = embedly_api.extract :url => url
    rescue
      return nil
    end

    if obj.blank?
      return
    end
    data = obj[0].marshal_dump

    if data.blank?
      return
    end

    scrape_data.description = data[:description]
    image_url = nil

    if data[:type].eql? 'video'
      scrape_data.type = 'video'
      unless data[:provider_name].blank?
        scrape_data.source_type = data[:provider_name].downcase
        if scrape_data.source_type.eql? 'youtube'
          scrape_data.video_id = scrape_data[:url][/(?<=[?&]v=)[^&$]+/]
          image_url = get_hd_youtube_image_url(scrape_data.video_id)
        elsif scrape_data.source_type.eql? 'vimeo'
          scrape_data.video_id = scrape_manager [:url][/(\d+)/]
        end
      end
    else
      scrape_data.type = 'article'
    end

    if image_url.blank?

      if data[:thumbnail_url].blank?
        image_url = data[:url]
        image_height = 400
        image_width = 400
      else
        image_url = data[:thumbnail_url]
        image_height = data[:thumbnail_height]
        image_width = data[:thumbnail_width]
      end

      if image_height <= 500 or image_width <= 500
        image_height = image_height * 2
        image_width = image_width * 2
      end

      begin
        upload_hash = Cloudinary::Uploader.upload(image_url,
                                                  :crop => :fit, :height => image_height, :width => image_width, :radius => 6,
                                                  :eager => [
                                                      {:width => image_height/2, :height => image_width/2,
                                                       :crop => :fit,
                                                       :radius => 6},
                                                      {:width => 150, :height => 150,
                                                       :radius => 6,
                                                       :crop => :fit, :format => 'png'}
                                                  ],
                                                  :tags => ['blog', data[:url]], :secure => true)
        scrape_data.large_image_url = upload_hash['secure_url']
        scrape_data.medium_image_url = upload_hash['eager'][0]['secure_url']
        scrape_data.small_image_url = upload_hash['eager'][1]['secure_url']
      rescue
        return
      end
    else
      scrape_data.large_image_url = image_url
    end

    scrape_data.create_date = Date.today
    feed_item = FeedItems.find_by(:subject_id => scrape_data.id)
    unless feed_item.blank?
      scrape_data.company_id = feed_item.poster_id
      feed_item[:large_image_url] = scrape_data.large_image_url
      feed_item[:medium_image_url] = scrape_data.medium_image_url
      feed_item[:small_image_url] = scrape_data.small_image_url
      feed_item[:description] = scrape_data.description
      begin
        feed_item.save
      rescue Exception => ex
      end
    end
    scrape_data.save
    scrape_data
  end

  def get_or_create_scrape_data(params, poster_id)
    get_scrape_data_for_url(params[:url], poster_id)
  end

  def create_scrape_data_marshal(data, user_id)
    id = ''
    user = get_user_by_handle(user_id)
    external_image = true
    if data[:title].blank?
      id = generate_id_from_text(data[:url])
    else
      id = generate_id_from_text(data[:title])
    end
    scrape_data = get_scrape_by_id(id)
    if scrape_data.blank?
      scrape_data = ScrapeData.new
    end

    unless id.blank?
      scrape_data.id = id
    end
    scrape_data.user_handle = user_id
    scrape_data.url = data[:url]
    scrape_data.description = data[:description]

    if data[:title].blank?
      scrape_data.title = data[:url]
    else
      scrape_data.title = data[:title]
    end

    unless data[:author_name].blank?
      scrape_data.author_name = data[:author_name]
    end

    unless data[:provider_url].blank?
      scrape_data.source_url = data[:provider_url]
    end

    image_url = nil

    if data[:type].eql? 'video'
      scrape_data.type = 'video'
      unless data[:provider_name].blank?
        scrape_data.source_type = data[:provider_name].downcase
        if scrape_data.source_type.eql? 'youtube'
          scrape_data.video_id = data[:url][/(?<=[?&]v=)[^&$]+/]
          image_url = get_hd_youtube_image_url(scrape_data.video_id)
        elsif scrape_data.source_type.eql? 'vimeo'
          scrape_data.video_id = data[:url][/(\d+)/]
        end
      end
    elsif data[:type].eql? 'photo'
      scrape_data.type = 'photo'
      image_url = data[:url]
    elsif data[:type].eql? 'image'
      scrape_data.type = 'article'
      scrape_data.title = '[Image]'
    elsif data[:type].eql? 'html'
      scrape_data.type = 'article'
    else
      scrape_data.type = 'article'
      external_image = false
      filepicker_id = filepicker_id(data[:url])
      if filepicker_id.blank?
        image_url = get_doc_thumbnail_for_type(data[:type])
        external_image = true
        scrape_data.title = "#{data[:provider_name]}"
      else
        file_stats = $fp_client.stat(filepicker_id)
        image_url = get_doc_thumbnail_for_type(file_stats['mimetype'])
        can_preview = is_previewable_format(data[:type])
        scrape_data.url = can_preview ? data[:url].sub("/file/", "/preview/") : data[:url]
        helper_text = "[#{can_preview ? 'Preview' : 'Download'} File]"
        if data[:title].blank?
          scrape_data.title = "#{file_stats['filename']} #{helper_text}"
        else
          scrape_data.title = "#{data[:title]} #{helper_text}"
        end
      end
    end

    stuff_image_scrape(scrape_data, data, image_url, external_image)

    unless data[:keywords].blank?
      scrape_data.tags = data[:keywords].map { |tag| [tag["name"], tag["score"] * 1.0/100] }.sort_by { |v| -v[1] }
    end
    if scrape_data.title.blank?
      if data[:title].blank?
        scrape_data.title = data[:url]
      else
        scrape_data.title = data[:title]
      end

    end

    scrape_data.create_date = Date.today
    scrape_data.poster_logo = user.image_url
    scrape_data.save
    scrape_data
  end


  def get_scrape_data_for_url(url, poster_id)
    begin
      embedly_api =
          Embedly::API.new :key => ENV['embedly_key'], :user_agent => 'Mozilla/5.0 (compatible; mytestapp/1.0; ravi@getmeed.com)'
      obj = embedly_api.extract :url => url
    rescue
      return nil
    end
    data = obj[0].marshal_dump
    unless data[:type].eql? 'photo'
      data[:url] = url
    end

    create_scrape_data_marshal(data, poster_id)
  end

  def get_scrape_data_from_upwork_url(url)
    data = {}
    response_text = HTTParty.get(url)
    unless response_text.blank?
      doc = Nokogiri::HTML(response_text)
      main_node = doc.at_xpath(".//div[@id='layout']/div[contains(@class, 'container')]")
      title_node = main_node.at_xpath("./div[contains(@class, 'row')][1]//h1")
      content_node = main_node.at_xpath("./div[contains(@class, 'row')][2]/div[1]")
      if content_node.blank?
        return data
      end
      sub_header_node = content_node.at_xpath("./div[contains(@class, 'row')]")
      job_type_node = sub_header_node.xpath(".//p[@class = 'm-0-bottom']")[0]
      sub_text_node = sub_header_node.at_xpath("./div[1]/div[2]/span")
      if !sub_text_node.blank? and sub_text_node.inner_text.include? 'More than'
        hourly_hours = sub_text_node.children()[0].inner_text.strip()
        unless hourly_hours.blank?
          matches = /More\s+than\s+(\d+)\s+hrs\/week\s*/.match(hourly_hours)
          if (!matches.blank? && matches.size > 1)
            hourly_hours = matches[1].to_i
          end
        end
        duration = sub_text_node.children()[2].inner_text.strip()
        unless duration.blank?
          duration = duration.sub('More than ', '')+' from now'
          duration = Chronic.parse(duration, :context => :future)
        end
      elsif !sub_text_node.blank? and sub_text_node.inner_text.include? 'Delivery by'
        end_date = sub_text_node.at_xpath(".//span")
        unless end_date.blank?
          end_date = end_date.inner_text.strip()
        end
        unless end_date.blank?
          end_date = Date.parse(end_date)
        end
      end
      price_node = sub_header_node.xpath(".//p[@class = 'm-0-bottom']")[1]
      body_node = content_node.at_xpath("./div[contains(@class, 'air-card-group')][1]/div[contains(@class, 'air-card')][1]")
      description_node = body_node.at_xpath("./p")
      skills_node = body_node.xpath("./span[2]")

      # constructing hash from nodes
      data[:url] = url
      unless title_node.blank?
        data[:title] = title_node.inner_text
      end
      data[:title] = (title_node.blank?) ? nil : title_node.inner_text.strip()
      data[:description] = (description_node.blank?) ? nil : description_node.inner_text
      data[:job_type] = (job_type_node.blank?) ? nil : get_job_type_from_upwork(job_type_node.inner_text.strip())
      data[:fixed_price] = (price_node.blank?) ? nil : price_node.inner_text.strip().sub('$', '')
      unless skills_node.blank?
        value = skills_node.attr("ng-init").value
        unless value.blank?
          skills_text = value.split("=")[2]
          skills = JSON.parse(skills_text).map { |s| s['prettyName'].downcase }
          data[:skills] = skills
        end
      end
      # replace hourly price if present
      if (data[:job_type] == JobType::MINIINTERN_HOURLY) && !duration.blank?
        data[:hourly_hours] = hourly_hours * ((duration - Time.now) / 1.week).round()
        # get end date for hourly
        data[:end_date] = duration
      end

      # for other cases use the original end date
      unless end_date.blank?
        data[:end_date] = end_date
      end

      return data
    end
  end
end