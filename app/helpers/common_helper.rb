module CommonHelper
  $youtube_regex = /youtube.com.*(?:\/|v=)([^&$]+)/
  $vimeo_regex = /vimeo.com.*(?:\/|v=)([^&$]+)/
  $id_generation_limit = 17
  SEARCH_ENGINE_BOTS = %w(googlebot bingbot msnbot adidxbot bingpreview googlebot-news googlebot-image googlebot-video mediapartners-google adsbot-google)
  Noun_tags = ["NN", "NNS", "NNP", "NNPS"]

  # overriding the definition of to_s for set

  def hide_email_address(text)
    splits = text.split(/.{0,4}@/)
    if !splits.blank? and splits.length > 1
      return "#{splits[0]} '** email hidden (please short list) **' #{splits[1].split(' ')[1..-1].join(' ')}"
    end
    text
  end

  def cookies_record_required_params(params)
    unless params[:referrer].blank?
      cookies[:referrer] = params[:referrer]
    end
    unless params[:referrer_id].blank?
      cookies[:referrer_id] = params[:referrer_id]
    end
    unless params[:referrer_type].blank?
      cookies[:referrer_type] = params[:referrer_type]
    end

    unless params[:campaign_type].blank?
      cookies[:campaign_type] = params[:campaign_type]
    end
  end

  def is_valid_email(email)
    email_regex = %r{
      ^ # Start of string
      [0-9a-z] # First character
      [0-9a-z.+_]+ # Middle characters
      [0-9a-z] # Last character
      @ # Separating @ character
      [0-9a-z] # Domain name begin
      [0-9a-z.-]+ # Domain name middle
      [0-9a-z] # Domain name end
      $ # End of string
    }xi

    (email =~ email_regex)
  end

  def encode_delimited_strings_char(strings, char)
    delimited_string = ''
    count = 0
    strings.each do |string|
      count = count + 1
      delimited_string << string
      if count != strings.length
        delimited_string << char
      end
    end
    delimited_string
  end

  def decode_delimited_strings_char(delimited_string, char)
    delimited_string.split(char)
  end

  def ordered_random_merge(a, b)
    if a.blank? and b.blank?
    end
    if a.blank?
      return b
    end

    if b.blank?
      return a
    end

    splits = a.each_slice(10).to_a
    merged_first_page = random_merge(splits[0], b)
    splits[0] = merged_first_page
    splits = splits.flatten
    results = []
    ob_ids = []
    splits.each do |ob|
      unless ob_ids.include? ob
        ob_ids << ob
        results << ob
      end
    end
    results
  end

  def random_merge(a, b)
    if a.blank?
      return b
    end

    if b.blank?
      return a
    end
    a, b = a.dup, b.dup
    a.map { rand(b.size+1) }.sort.reverse.each do |index|
      b.insert(index, a.pop)
    end
    b
  end

  def get_selects_from_params(params, select_type)
    selects = Array.new
    params.each do |key, value|
      split_key = key.split('_')[0].to_s
      split_value = key.split('_')[1].to_s
      if (split_key.eql? select_type)
        selects << split_value
      end
    end
    selects
  end

  def is_valid_link(link)
    (link =~ /^https?:/)
  end

  def decode_ids(ids)
    decode_ids = Array.[]
    ids.each do |id|
      decode_ids << decode_id(id)
    end
    decode_ids
  end

  def decode_id(id)
    if id.blank?
      return nil
    end
    id.base62_decode.to_s(16)
  end

  def encode_id(id)
    id.to_s.to_i(16).base62_encode
  end

  def process_text(input)
    input = Sanitize.fragment(input, :elements => %w(ul li i b br))
    input = text_put_line_breaks(input)
    input = sanitize_multiple_lines(input)
    anchorify_link(input)
  end

  def sanitize_text(input)
    Sanitize.clean(input)
  end

  def scrub_input_text(input)
    if input.blank?
      return ''
    end
    input = text_put_line_breaks(input)
    input = text_put_bold_tags(input)
    input = text_insert_bullets(input)
    input = anchorify_link(input)
    input
  end

  def sanitize_group_description(text)
    return ActionView::Base.full_sanitizer.sanitize(text, :tags => []).gsub("\r", '')
  end

  def sanitize_description_text(text)
    if text.blank?
      return nil
    end
    text = text_remove_line_breaks(text)
    text = text.gsub(/\s+/, ' ')
    return text
  end

  def sanitize_multiple_lines(input)
    if input.blank?
      return
    end

    words = input.split('<br>')

    #the format is good, so return without sanitization
    if words.length < 6
      return input
    end
    result = ''
    words.each do |word|
      if word.length < 100
        result << word
      else
        result << word
        result << '<br>'
      end
    end
    result
  end

  def text_put_line_breaks(input)
    if input.blank?
      return
    end
    input.gsub(/(?m)\n/, '<br/>')
  end

  def text_put_bold_tags(input)
    input = input.gsub(/(?m)bold>/, 'strong>')
    input = input.gsub(/(?m)b>/, 'strong>')
    input
  end

  def process_handle(input)
    new_input = input.gsub(' ', '-')
    new_input.gsub('.', '-')
  end

  def text_remove_line_breaks(input)
    input.gsub('<br/>', '').gsub('\n', '')
  end

  def get_selected_items_from_params (params, prefix_string)
    items_list = Array.[]
    params.each do |key, value|
      split_key = key.split('_')[0]
      if split_key.eql? prefix_string
        item_value = String.new key
        item_value.slice! prefix_string + '_'
        unless item_value.eql? 'all_checkbox'
          items_list << item_value
        end
      end
    end
    items_list
  end

  def build_comma_separated_string (collects)
    return_string = ''
    if (!collects.blank?)
      count = 0
      collects.each do |collect|
        return_string << collect
        count += 1
        if collects.length != count
          return_string << ', '
        end
      end
    end
    return_string
  end

  def compare(a, b)
    return 0 if a.blank? or b.blank?
    b <=> a
  end

  def compare_score(a, b)
    return 0 if a.blank? or b.blank?
    b.to_f <=> a.to_f
  end

  def get_feed_key(school_handle, major)
    if school_handle.blank? or major.blank?
      return ''
    end
    school_handle + '_' + major
  end

  def capitalize_delimited_text(text, delimiter='-')
    result = ''
    if text.blank?
      return result
    end
    chomps = text.split(delimiter)
    result = chomps[0].capitalize
    chomps[1..chomps.length-1].each do |chomp|
      result = "#{result} #{chomp.capitalize}"
    end
    result
  end

  def generate_id_from_text(input, char='-')
    if input.blank?
      return nil
    end
    input = input.sub(/\s+\Z/, '')
    input = input.downcase
    input = input.gsub(' ', char).gsub(/[^a-zA-Z0-9\\_\-\.]/, '')
    input = input.gsub('.', '').gsub(/[^a-zA-Z0-9\\_\-\.]/, char)
    input = input.gsub('--', char).gsub(/[^a-zA-Z0-9\\_\-\.]/, char)
    input = input.chomp(char)
    input
  end

  def remove_trailing_space_comma(str)
    str.chomp(' ') if (str)
    str.chomp(',') if (str)
  end

  def condense_text(input)
    input_array = input.split('-')
    output_string = input_array[0]
    count = 0
    skip_first = false
    input_array.each do |word|
      if !skip_first
        skip_first = true
      elsif count < $id_generation_limit
        output_string << '-' << word
        count += 1
      end
    end
    output_string
  end

  def text_remove_spaces(input, char)
    input.gsub(' ', char)
  end

  def text_insert_bullets(input)
    input = input.gsub(/(?m)<bullet>/, '<ul class="ul-bullet">
            <li><span>')
    input = input.gsub(/(?m)<\/bullet>/, '</span></li></ul>')
    input
  end

  def anchorify_link(input)
    if input.blank?
      return input
    end

    urls = %r{(?:https?|ftp|mailto)://\S+}i
    html = input.gsub urls, '<a href="\0" target="_blank">\0</a>'
    html
  end

  def get_promotion_metadata(promotion_type, user)
    metadata = Hash.new
    metadata[:title] = 'Join Meed - where students build careers'
    metadata[:description] = 'Students join meed to build their professional reputation identified by employers'
    metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/c_scale,w_1000/v1448651512/Screen_Shot_2015-11-27_at_11.05.18_AM_ov4ds1.png'
    if user.blank?
      if promotion_type.eql? 'lb'
        metadata[:title] = 'Join Meed'
        metadata[:description] = 'Meed - A Professional community for students'
      end
    else
      metadata[:title] = "Join #{user.first_name} on Meed!"
      metadata[:description] = 'Meed - A Professional community for students'
      metadata[:image_url] = "#{user.large_image_url}"
    end


    if promotion_type.eql? 'needmeed'
      metadata[:title] = 'Join Meed - where students build careers'
      metadata[:description] = 'The Largest Professional Platform is now coming to your University.'
      metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/c_crop,h_350,w_800/v1445216005/Ineedmeed_hto0ye.jpg'
    end

    if promotion_type.eql? 'chipotle'
      metadata[:title] = 'Join Meed - where students build careers'
      metadata[:description] = 'The Largest Professional Platform is now coming to your University. Earn $100 Chipotle gift card and instant access to Meed.'
      metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/c_crop,h_160,w_500/v1445452705/MeedxChipotle_wlddlu.png'
    end
    if promotion_type.eql? 'jobs'
      metadata[:title] = 'Join Meed - where students build careers'
      metadata[:description] = 'The Largest Professional Platform is now coming to your University. Act Now and get instant access to over 1500 jobs that are actively hiring.'
      metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/c_crop,h_350,w_800/v1445216005/Ineedmeed_hto0ye.jpg'
    end
    if promotion_type.eql? 'hbo_now'
      metadata[:title] = 'Join Meed - where students build careers'
      metadata[:description] = 'The Professional Platform is now coming to your University. Act Now and get instant access to over 1500 jobs that are actively hiring.'
      metadata[:image_url] = 'http://res.cloudinary.com/resume/image/upload/v1446251879/HBO_Now_Mindsumo_bklf6y.jpg'
    end
    if promotion_type.eql? 'recref'
      metadata[:title] = 'Join Meed - where students build careers'
      metadata[:description] = 'The Largest Professional Platform is now coming to your University. Act Now and get connected to recruiter from any company.'
      metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/c_crop,h_350,w_800/v1445216005/Ineedmeed_hto0ye.jpg'
    end
    metadata
  end


  def get_promo_metadata(inviter_first_name)
    metadata = Hash.new
    if inviter_first_name.blank?
      metadata[:title] = 'Join Meed to connect with companies!'
    else
      metadata[:title] = "Join #{inviter_first_name} on Meed!"
    end
    metadata[:description] = 'Meed — Career marketplace for students and employers'
    metadata[:image_url] = 'https://res.cloudinary.com/resume/image/upload/v1442333087/safe_image.php_fk44cx.jpg'
    metadata
  end

  def get_career_fair_metadata
    metadata = Hash.new
    metadata[:title] = 'Sign up for Meed Fair Summer 2015!'
    metadata[:description] = 'Meed — Sign up before May 31st to apply for last minute internships and jobs!'
    metadata[:image_url] = 'http://res.cloudinary.com/resume/image/upload/c_scale,w_1000/v1429739195/16306814233_203c3de717_o_j81hmx.jpg'
    metadata
  end

  def process_links(input)
    if !input.blank? and input.start_with? 'www.'
      'http://'.<< input
    end
    input
  end

  def get_tokens(text)
    if text.blank?
      return []
    end
    text = sanitize_html_text(text)
    #words = text.tokenize().words;
    #return words.map{|word| word.to_s}
    return text.split()
  end

  def sanitize_html_text(text)
    if text.nil?
      return nil
    end
    #text = text.downcase
    text = ActionController::Base.helpers.strip_tags(text)
    if text.blank?
      return nil
    end
    text = text.gsub(/&nbsp;/i, '')
    # Explore stemming as it is not very expensive
    return text
  end

  def filter_keywords_by_skills(keywords)
    # check for keywords that are present in the kills (part of it - but whole word).
    return keywords.select { |keyword| !keyword.blank? & !!Futura::Application.config.skill_hist.keys.detect { |k| k.to_s =~ /#{Regexp.escape(keyword)}(\s|$)/ } }
  end

  # returns sanitized skills strings from a single string
  def generate_skills(skills)
    if skills.blank?
      return []
    end
    if skills.kind_of?(String)
      return skills.split(',').collect { |s| s.strip().downcase() };
    else
      return skills
    end
  end

  def get_skills_in_text(text)
    if text.blank?
      return []
    end
    text = sanitize_html_text(text)
    return Futura::Application.config.skill_hist.keys.select { |k| !(/\W#{Regexp.escape(k)}\W/.match(text).blank?) }
  end

  def save_redirect_url(params)
    unless params[:redirect_url].blank?
      cookies[:redirect_url] = params[:redirect_url]
    end
  end


  def follow_redirect_url
    unless cookies[:redirect_url].blank?
      # remove the cookie and redirect
      redirect_url = cookies[:redirect_url]
      cookies.delete :redirect_url
      redirect_to redirect_url and return true
    end
  end

  # DRY'ing up error responses
  def error_redirect msg, redirect_url, extras = {}
    respond_to do |format|
      format.html {
        flash[:alert] = msg
        return redirect_to redirect_url
      }
      format.json {
        return render json: {success: false, error: msg, redirect_url: redirect_url}.merge(extras)
      }
    end
  end

  def error_render msg, template, extras = {}
    respond_to do |format|
      format.html {
        flash[:alert] = msg
        return render :template => template
      }
      format.json {
        return render json: {success: false, error: msg}.merge(extras)
      }
    end
  end

  def get_histogram(array, sort=true)
    v = array.group_by { |t| t }.map { |k, v| [k, v.count()] }
    if sort
      v = v.sort_by { |p| -p[1] }
    end
    return v
  end


end

class Set
  def to_s
    return self.to_a.to_s
  end

  alias :inspect :to_s
end
