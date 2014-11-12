ActiveAdmin.register_page 'Dashboard' do

  menu priority: 1, label: proc { 'Feeds' }

  controller do
  end

  content title: proc { 'Feeds'  } do
    columns do
      column do
        sort = (params[:order] || '').gsub('_desc', ' desc').gsub('_asc', ' asc')
        feeds = Feed.eager_load(:feed_requests).eager_load(:feed_items).order(sort)
        paginated_collection(feeds.page(params[:page]).per(15), download_links: false) do
          table_for collection, sortable: true do
            column :url, sortable: 'feeds.url' do |feed|
              link_to feed.url, admin_feed_path(feed)
            end
            column('Request #', sortable: 'feed_requests.count') { |feed| feed.feed_requests.count }
            column('Item #', sortable: 'feed_items_count') { |feed| feed.feed_items.count }
            column('Last Active', sortable: false) { |feed| feed.feed_items.last.try(:created_at) }
          end
        end
      end
    end
  end
end
