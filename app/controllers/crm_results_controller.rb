class CrmResultsController < ApplicationController
  # GET /crm_results
  # GET /crm_results.json
  def index
    unless authenticate(current_user)
      return
    end

    @crm_results = CrmResults.all.sort_by!(&:update_dttm).reverse!
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @crm_results }
    end
  end

  # GET /crm_results/1
  # GET /crm_results/1.json
  def show
    unless authenticate(current_user)
      return
    end

    @crm_result = CrmResults.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @crm_result }
    end
  end

  # GET /crm_results/new
  # GET /crm_results/new.json
  def new
    unless authenticate(current_user)
      return
    end

    @crm_result = CrmResults.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @crm_result }
    end
  end

  # GET /crm_results/1/edit
  def edit
    unless authenticate(current_user)
      return
    end

    @crm_result = CrmResults.find(params[:id])
  end

  # POST /crm_results
  # POST /crm_results.json
  def create
    unless authenticate(current_user)
      return
    end

    @crm_result = CrmResults.new(params[:crm_result])

    respond_to do |format|
      if @crm_result.save
        format.html { redirect_to @crm_result, notice: 'Crm result was successfully created.' }
        format.json { render json: @crm_result, status: :created, location: @crm_result }
      else
        format.html { render action: "new" }
        format.json { render json: @crm_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /crm_results/1
  # PUT /crm_results/1.json
  def update
    unless authenticate(current_user)
      return
    end

    @crm_result = CrmResults.find(params[:id])

    respond_to do |format|
      if @crm_result.update_attributes(params[:crm_result])
        format.html { redirect_to @crm_result, notice: 'Crm result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @crm_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /crm_results/1
  # DELETE /crm_results/1.json
  def destroy
    @crm_result = CrmResults.find(params[:id])
    @crm_result.destroy

    respond_to do |format|
      format.html { redirect_to crm_results_url }
      format.json { head :no_content }
    end
  end
end
