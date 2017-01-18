module ConnectionsManager
  include UsersManager

  def get_or_create_contacts_book(handle)
    contacts_book = ContactsBook.find(handle)
    unless contacts_book.blank?
      return contacts_book
    end
    contacts = Array.[]
    contacts_book = ContactsBook.new
    contacts_book.handle = handle
    contacts_book.id = handle
    contacts_book.contacts = contacts
    contacts_book.save
    contacts_book
  end

  def save_facebook_connections(handle, friends)
    if handle.blank? or friends.blank?
      return
    end
    friends.each do |friend|
      social_connection = SocialConnection.new
      social_connection.connected_handle = handle
      name_splits = friend['name'].split(' ')[0]
      social_connection.social_network = 'facebook'
      social_connection.first_name = name_splits[0]
      social_connection.last_name = name_splits[1]
      social_connection.picture_url = friend['picture']
      social_connection.save
    end
    save_user_state(handle, UserStateTypes::FACEBOOK_IMPORT)

  end

  def save_contacts_book(handle, contacts_hash)
    contacts_book = get_or_create_contacts_book(handle)
    current_contacts = contacts_book.contacts

    contacts_map = Hash.new
    current_contacts.each do |contact|
      contacts_map[contact.email] = contact
    end

    contacts_hash.each do |contact_hash|
      contact = contacts_map[contact_hash[:email]]
      if contact.blank?
        contact = Contact.new
        contact.email = contact_hash[:email]
        contact.first_name = contact_hash[:first_name]
        contact.last_name = contact_hash[:last_name]
        contacts_book.contacts.push(contact)
      end
    end
    contacts_book.save
  end

  def save_connections(handle, user_ids)
    if user_ids.blank?
      return
    end
    connections = Connections.find(handle)
    if connections.blank?
      connections = Connections.new
      connections.handle = handle
      connections.id = handle
      connections.set(:user_ids, user_ids)
    else
      connections.add_to_set(:user_ids, user_ids)
    end
    connections.save
    create_passive_users(user_ids)
    connections
  end

  def create_meed_friend_connection(handle, friend_handle)
    if handle.blank? or friend_handle.blank?
      return
    end

    id = "#{handle}_#{friend_handle}"
    reverse_id = "#{friend_handle}_#{handle}"
    create_meed_friend(id, handle, friend_handle)
    create_meed_friend(reverse_id, friend_handle, handle)
  end

  def create_meed_friend(id, handle, friend_handle)
    friend = MeedFriend.find(id)
    if friend.blank?
      friend = MeedFriend.new
      friend.id = id
      friend.handle = handle
      friend.friend_handle = friend_handle
      friend.save
    end
  end


end