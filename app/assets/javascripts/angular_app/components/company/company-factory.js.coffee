CompanyFactory = (MeedApiFactory) ->
  fixed = () ->
    { hi: "there" }

  getAllCompanies = () ->
    MeedApiFactory.get("/company/list/all")

  getCompany = (companySlug) ->
    MeedApiFactory.get("/company/#{companySlug}")

  # Follow a company
  follow = (company_id) ->
    url  = "/company/follow/#{company_id}"
    MeedApiFactory.post(url)

  unfollow = (company_id) ->
    url  = "/company/unfollow/#{company_id}"
    MeedApiFactory.post(url)

  getCompanyRecommendations = () ->
    MeedApiFactory.get('/user/company/recommendations')

  return {
    fixed: fixed
    getCompany: getCompany
    follow: follow
    unfollow: unfollow
    getCompanyRecommendations: getCompanyRecommendations
    getAllCompanies: getAllCompanies
  }

CompanyFactory.$inject = [
  "MeedApiFactory"
]

angular.module("meed").factory "CompanyFactory", CompanyFactory
