module ClearbitManager

  Industries = ["Media", "Automobiles", "Distributors", "Household Durables", "Hotels, Restaurants & Leisure",
                "Auto Components", "Leisure Products", "Speciality Retail", "Internet & Catalog Retail",
                "Multiline Retail", "Food Products", "Oil, Gas & Consumable Fuels", "Energy Equipment & Services",
                "Banks", "Capital Markets", "Insurance", "Real Estate Investment Trusts", "Consumer Finance",
                "Thrifts & Mortgage Finance", "Health Care Providers & Services", "Biotechnology", "Pharmaceuticals",
                "Health Care Equipment & Supplies", "Professional Services", "Aerospace & Defense",
                "Construction & Engineering", "Electrical Equipment", "Building Products", "Airlines", "Machinery",
                "Marine", "Road & Rail", "IT Services", "Software", "Technology Hardware, Storage & Peripherals",
                "Electronic Equipment, Instruments & Components", "Communications Equipment",
                "Technology Hardware, Storage & Peripherals", "Semiconductors & Semiconductor Equipment",
                "Construction Materials", "Chemicals", "Metals & Mining", "Advertisting", "Movies & Entertainment",
                "Systems Software", "Application Software"]
  def get_companies_by_industry(industry, result_count=100, sort_by='employees')
    pages = (result_count / 10.0).ceil
    results = []
    (1..pages).each do |page|
      page_results = Clearbit::Discovery.search({
                                                    query: [{industry: industry}, {country: 'US'}],
                                                    sort: sort_by,
                                                    page: page
                                                })
      if page_results.blank? or page_results["results"].blank?
        break
      end
      results.concat(page_results["results"])
    end
    return results
  end

  def get_best_company_by_name(name)
    results = Clearbit::Discovery.search({
                                             query: {name: name},
                                             sort: 'google_rank',
                                             page_size: 1
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results'].first
    end
  end

  def remove_subdomain(host)
    # Not complete. Add all root domain to regexp
    host.sub(/.*?([^.]+(\.com|\.co\.uk|\.uk|\.nl))$/, "\\1")
  end

  def get_company_by_domain(domain)
    results = Clearbit::Discovery.search({
                                             query: {domain: domain},
                                             sort: 'google_rank',
                                             page_size: 1
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results'].first
    end
  end

  def get_company_by_url(url)
    # getting host just incase
    host = URI.parse(url).host.downcase
    result = get_company_by_domain(host)
    if result.blank?
      host = remove_subdomain(host)
      result = get_company_by_domain(host)
    end
    return result
  end

  def get_company_by_industry(industry, page_size=1, sort='google_rank')
    results = Clearbit::Discovery.search({
                                             query: {industry: industry, country: 'US'},
                                             sort: sort,
                                             page_size: page_size
                                         })
    if results.blank? or results['results'].blank?
      return nil
    else
      return results['results']
    end
  end
end