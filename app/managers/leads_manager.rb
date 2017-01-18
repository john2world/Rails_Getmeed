module LeadsManager
  include IntercomHelper
  include IntercomManager
  include UsersHelper
  def create_leads_from_intercom_tag(tagname)
    contacts = get_contacts_by_tag(tagname, 100000)
    if contacts.blank?
      return
    end
    # bulk insert contacts to Leads
    leads = []
    contacts.each do |contact|
      if contact.blank?
        next
      end
      ca = contact.custom_attributes
      if ca.blank?
        next
      end
      leads.push({:_id => contact.email, :first_name => contact.name, :last_name => ca['Last Name'], :email => contact.email,
                  :major_text => nil, :major => ca['major'], :major_id => ca['major_id'],
                  :department_text => ca['department_text'], :year => ca['year']})
    end
    Lead.collection.insert(leads)
  end

  def search_leads(user, search_term = nil, limit = 6)
    # if search_term is nil make it "*"
    if user.blank?
      return []
    end
    if search_term.blank?
      search_term = '*'
    end
    # filter by school
    school = get_school_handle_from_email(user.id)
    # see if the user is already preset as a lead
    lead = Lead.find(user.id)
    year = lead.blank? ? user.year : lead.year
    major_id = lead.blank? ? user.major_id : lead.major_id
    major = lead.blank? ? user.major : lead.major
    major_text = lead.blank? ? nil : lead.major_text
    department_text = lead.blank? ? nil : lead.department_text

    # make year, major_id, major, department_text and year as boost
    result = Lead.search search_term,
                fields: [:first_name, :last_name],
                where: {school: school},
                boost_where: {
                    year: [{value: year, factor: 10}],
                    major_id: [{value: major_id, factor: 10}],
                    major: [{value: major, factor: 10}],
                    major_text: [{value: major_text, factor: 10}],
                    department_text: [{value: department_text, factor: 10}],
                },
                limit: limit
    result.to_a
  end

  def get_lead_by_email(lead_email)
    return Lead.find(lead_email)
  end

  def get_intercom_lead_by_email(lead_email)
    leads = search_lead_by_email(lead_email)
    if leads.blank?
      return nil
    end
    lead = leads[0]
    # mapping the attributes
    lead_obj = {}
    lead_obj[:id] = lead['email']
    if lead['name'].blank?
      name = ''
    else
      name = lead['name'].strip()
    end
    lead_obj[:first_name] = name.split(' ').first
    lead_obj[:last_name] = name.split(' ').last
    lead_obj[:email] = lead['email']
    custom_data = lead['custom_data']
    lead_obj[:major_text] = custom_data['major']
    lead_obj[:major_id] = custom_data['major_id']
    lead_obj[:year] = custom_data['year']
    return lead_obj
  end
end