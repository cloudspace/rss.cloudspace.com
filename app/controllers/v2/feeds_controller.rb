# For the v2/feeds endpoints
class V2::FeedsController < ApplicationController
  # GET /v2/feeds/default
  def default
    feeds = Feed.default
    status = :ok
    render json: feeds, status: status, each_serializer: V2::Feeds::FeedSerializer
  end

  # GET /v2/feeds/search
  def search
    if params[:name].present?
      feeds = Feed.search_name(params[:name])
      status = :ok
    else
      status = :bad_request
    end

    render json: feeds, status: status, each_serializer: V2::Feeds::FeedSerializer
  end

  # POST /v2/feeds/create
  def create
    if params[:url].present?
      new_feed = Feed.generate_from_url(params[:url])
      if new_feed
        status = :created
      else
        status = :unprocessable_entity
      end
    else
      status = :bad_request
    end

    render nothing: true, status: status
  end
end
