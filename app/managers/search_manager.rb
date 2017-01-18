module SearchManager
  include LinkHelper
  def multiindex_dashboard_search(query, limit = 10)
    results = {}
    results[:jobs] = job_dashboard_search(query, limit)
    results[:users] = profile_dashboard_search(query, limit)
    results[:companies] = company_dashboard_search(query, limit)
    results
  end

  def job_dashboard_search(query, limit = 10)
    job_search = Job.search query, execute: false,
                            fields: [:title, :company, {skills: :exact}],
                            where: {type: ['full_time_entry_level', 'Internship', 'full_time_experienced']},
                            limit: limit
    return job_search.execute.map{|j| {title: j.title, logo: j.company_logo, company: j.company, url: get_job_url(encode_id(j.id)), type: 'job'}}
  end

  def profile_dashboard_search(query, limit = 10)
    profile_search = Profile.search query, fields: [:name], execute: false, limit: limit
    handles = profile_search.execute.map(&:handle)
    users = User.where(:handle.in => handles)
    return users.map{|u| {name: u.name, logo: u.image_url, url: get_user_profile_url(u.handle), type: 'user'}}
  end

  def company_dashboard_search(query, limit=10)
    company_search = Company.search query, fields: [:name], execute: false, limit: limit
    return company_search.execute.map{|c| {title: c.name, logo: c.company_logo, url: get_company_url(c.id), type: 'company'}}
  end
end