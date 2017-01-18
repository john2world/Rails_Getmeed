class StoriesController < ApplicationController
  before_filter :logged_in?, except: [:index, :show]
  before_filter :render_angular_for_html_request, except: [:show]
  before_filter :set_story, only: [:edit, :update, :delete]

  def index
    @stories = Story.all
    render json: @stories
  end

  def show
    @story = Story.find(params[:id])
    build_feed_models(current_user, [@story.feed_item])
    set_page_title_and_meta
    render_angular_for_html_request
    FeedItemService.increment_feed_view_count @story.id
  end

  def new
    @story = Story.new
    if @story.stuff_questions_and_tags params[:type]
      render
    else
      head :bad_request
    end
  end

  def edit
    if @story
      @story.stuff_questions_and_tags @story.type
      render :new
    else
      head :not_found
    end
  end

  def create
    params[:story][:company_id] = create_company_by_name(params[:story][:company_id]).id unless Company.where(id: params[:story][:company_id]).first
    @story = Story.new params[:story]
    @story.user = current_user

    if @story.save
      render :show
    else
      render json: @story.errors, status: :unprocessable_entity
    end
  end

  def update
    if @story.update_attributes params[:story]
      render :show
    else
      render json: @story.errors, status: :unprocessable_entity
    end
  end

  def delete
    @story.destroy

    head :no_content
  end

private
  def set_story
    @story = Story.where(user_id: current_user.handle).find params[:id]
  end

  def set_page_title_and_meta
    page_title @story.title
    @metadata = @story.get_metadata
  end
end
