module MessagesManager
  include CommonHelper
  include QuestionsManager
  include UsersHelper
  include EnterpriseUsersManager
  include JobsManager
  include LinkHelper
  include UsersManager
  include ActionView::Helpers::DateHelper
  $Messages_PAGE_SIZE = 12

  def get_messages(handle)
    user_message_ids = UserMessages.where(:handle => handle).pluck(:message_ids).first
    user_messages = Message.any_in(:_id => user_message_ids).desc(:posted_dttm).to_a
    sender_ids = Array.[]
    user_messages.each do |message|
      message[:hash] = encode_id(message.id)
      unless message.from_email.blank?
        sender_ids << message.from_email
      end
    end
    sender_map = get_users_map_ids(sender_ids)
    sender_enterpriser_map = get_enterprisers_map(sender_ids)
    results = Array.[]
    user_messages.each do |message|
      sender = sender_enterpriser_map[message[:from_email]]
      if sender.blank?
        sender = sender_map[message[:from_email]]
        unless sender.blank?
          sender[:title] = "#{get_school_handle_from_email(sender.id).upcase}"
        end
      else
        sender_company = get_sender_company(sender)
        unless sender_company.blank?
          sender[:title] = "#{sender.title}"
        end
      end

      #if sender is still blank
      if sender.blank?
        sender = EnterpriseUser.new
        sender.id = message[:from_email].downcase
        sender.first_name = message[:from_email]
      end

      unless sender.blank?
        message[:hash] = encode_id(message.id)
        message[:sender] = sender
        results << message
      end
    end
    results
  end

  def reply_to_user(sender, message, subject, body)
    # get user
    user = User.find(message[:from_email])
    if user.blank?
      return false
    end

    message = save_message(message[:from_email], sender[:email], user[:handle], subject, body)

    user_messages = UserMessages.find(user[:handle])
    if user_messages.blank?
      user_messages = UserMessages.new(handle: user[:handle])
    end

    user_messages.push(:message_ids, message[:_id])
    user_messages.save
    EmailMessageWorker.perform_async(user[:email], false)
  end

  def new_message_to_user(sender, recipient_handle, subject, body)
    user = get_active_user_by_handle(recipient_handle);
    if user.blank?
      return false
    end

    if sender.id.eql? user.id
      return false
    end


    message = save_message(user.id, sender[:_id], user.handle, subject, body)
    user_messages = UserMessages.find(user[:handle])
    if user_messages.blank?
      user_messages = UserMessages.new(handle: user[:handle])
    end

    user_messages.push(:message_ids, message[:_id])
    user_messages.save
    # EmailMessageWorker.perform_async(user[:email], false)
  end

  def get_unread_message_count(id)
    Message.where(:email => id, :status => 'new').count
  end

  def save_message(to_email, from_email, handle, subject, body)
    message = Message.new
    message.email = to_email
    message.from_email = from_email
    message.handle = handle
    message.subject = subject
    message.body = body
    message.status = 'new'
    message.posted_dttm = Time.zone.now
    message.save
    message
  end

  def get_message_by_id(id)
    message = Message.find(id)
    if message.blank?
      return message
    end

    #enterpriser
    sender = get_enterpriser_by_email(message[:from_email])
    if sender.blank?

      #student
      sender = get_user_by_email(message[:from_email])

      #stranger
      if sender.blank?
        sender = EnterpriseUser.new
        sender.id = message[:from_email].downcase
        sender.first_name = message[:from_email]
      else
        sender[:title] = "#{get_school_handle_from_email(sender.id).upcase}"
        sender[:url] = get_user_profile_url(sender.handle)
      end
    else
      sender[:title] = "#{sender.title}"
      sender_company = get_sender_company(sender)
      unless sender_company.blank?
        sender[:title] = "#{sender.title}, #{sender_company.name}"
      end
    end

    unless sender.blank?
      message[:hash] = encode_id(message.id)
      message[:sender] = sender
    end
    message
  end

  def get_message_by_hash(hash)
    get_message_by_id(decode_id(hash))
  end

  # authenticates if the message belongs to the user
  def authenticate_message(hash, message)
    if hash.blank? or message.blank?
      return false
    end
    hash == message[:handle]
  end

  def update_message_status(id, status)
    message = Message.find(id)
    unless message.blank?
      message.status = status
      message.save
    end
  end

  def get_message_sender(message)
    if message.blank? or message[:from_email].blank?
      return nil
    end
    enterpriser = EnterpriseUser.find(message[:from_email])
    if enterpriser.blank?
      return get_user_by_email(message[:from_email])
    end
    enterpriser
  end

  def get_sender_company(sender)
    if sender.blank? or sender[:company_id].blank?
      return nil
    end
    Company.find(sender[:company_id])
  end

  def get_sender_full_name(sender)
    if sender.blank?
      return nil
    end
    '%s %s' % [sender.first_name, sender.last_name]
  end

  def get_sender_desc(sender, company)
    if sender.blank?
      return nil
    end
    oneliner = ""
    if sender[:title].blank?
      return oneliner
    end

    oneliner += "%s" % sender[:title]

    if company.blank?
      return oneliner
    end

    oneliner += " at %s" %company[:name]

    return oneliner
  end

  def build_message_model(message)
    sender = get_message_sender(message)
    company = get_sender_company(sender)
    unless company.blank?
      message[:company_logo] = company[:company_logo]
      message[:company_name] = company[:name]
    end
    message[:sender_name] = get_sender_full_name(sender)
    message[:sender_desc] = get_sender_desc(sender, company)
    unless message[:posted_dttm].blank?
      message[:time_ago] = time_ago_in_words(message[:posted_dttm]) + " ago"
    end
    message[:hash] = encode_id(message[:_id])
    message
  end

  def send_message_to_enterpriser(user, recipient_email, subject, body)
    # get enterprise user id
    enterprise_user = EnterpriseUser.find(recipient_email)
    if enterprise_user.blank?
      return false
    end

    # create a new message to recruiter
    message = save_message(enterprise_user[:_id], user.id, enterprise_user[:_id], subject, body)

    recruiter_messages = EnterpriseUserMessages.find(enterprise_user[:_id])
    if recruiter_messages.blank?
      recruiter_messages = EnterpriseUserMessages.new(handle: enterprise_user[:_id])
    end

    recruiter_messages.push(:message_ids, message[:_id])
    recruiter_messages.save
    if Rails.env.development?
      # Notifier.email_enterprise_message(message, user).deliver
    else
      EmailEnterpriseWorker.perform_async(message.id.to_s)
    end

  end

  def reply_message_to_enterpriser(user, message, subject, body)
    # get enterprise user id
    enterprise_user = EnterpriseUser.find(message[:from_email])
    if enterprise_user.blank?
      return false
    end

    # create a new message to recruiter
    message = save_message(enterprise_user[:_id], user.id, enterprise_user[:_id], subject, body)

    recruiter_messages = EnterpriseUserMessages.find(enterprise_user[:_id])
    if recruiter_messages.blank?
      recruiter_messages = EnterpriseUserMessages.new(handle: enterprise_user[:_id])
    end

    recruiter_messages.push(:message_ids, message[:_id])
    recruiter_messages.save
    EmailMessageWorker.perform_async(enterprise_user[:_id], true)
  end
end
