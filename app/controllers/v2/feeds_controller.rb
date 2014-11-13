# For the v2/feeds endpoints
class V2::FeedsController < ApiController
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
      feeds = Feed.search_name(params[:name]).limit(10)
      status = :ok
    else
      status = :bad_request
    end

    render json: feeds, status: status, each_serializer: V2::Feeds::FeedWithoutItemsSerializer
  end

  # POST /v2/feeds/create
  def create
    if params[:url].present?
      status = ensure_feed

      return render(nothing: true, status: status) if status == :unprocessable_entity

      FeedRequest.find_or_create_by(feed_id: current_feed.id).count_update
    else
      return render nothing: true, status: :bad_request
    end

    render json: [current_feed], status: status, each_serializer: V2::Feeds::FeedSerializer
  end

  def ensure_feed
    if (@current_feed = Feed.find_by(url: params[:url] && URI(params[:url]).normalize.to_s))
      :ok
    else
      current_feed ? :created : :unprocessable_entity
    end
  end

  def current_feed
    @current_feed ||= Feed.find_or_generate_by_url(params[:url])
  end
end
