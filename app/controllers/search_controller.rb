class SearchController < ApplicationController
  include SearchManager
  def dashboard_search
    results = {}
    if !params[:query].blank?
      results = multiindex_dashboard_search(params[:query], 6)
    elsif !params[:job].blank?
      results[:jobs] = job_dashboard_search(params[:job], 6)
    elsif !params[:user].blank?
      results[:users] = profile_dashboard_search(params[:user], 6)
    elsif !params[:company].blank?
      results[:companies] = company_dashboard_search(params[:company], 6)
    end
    # mapping only the essential fields
    respond_to do |format|
      format.html # view.html.erb
      format.json {
        return render json: {results: results}
      }
    end
  end
end