# For the v2/feeds endpoints
class V2::FeedsController < ApplicationController
  # GET /v2/feeds/:id
  def show
    feed = Feed.find_by(id: params[:id])
    if feed
      render json: [feed], status: status, each_serializer: V2::Feeds::FeedSerializer
    else
      render nothing: true, status: :not_found
    end
  end

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
      feed = Feed.find_by(url: URI(params[:url]).normalize.to_s)
      if feed
        status = :ok
      else
        feed = Feed.find_or_generate_by_url(params[:url])
        return render nothing: true, status: :unprocessable_entity unless feed
        status = :created
      end
    else
      return render nothing: true, status: :bad_request
    end

    render json: [feed], status: status, each_serializer: V2::Feeds::FeedSerializer
  end
end
