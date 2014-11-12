ActiveAdmin.register_page 'Processed' do

  menu priority: 2, label: proc { 'Processed' }

  content title: proc { 'Processed' } do
    columns do

      column do
        feed_items = FeedItem.where('process_start is not null and process_end is not null')
        if params[:order]
          item_order_query, item_ordering = processing_order_string_for('item')
          feed_items = feed_items.order(item_order_query)
        else
          item_ordering = 'item-desc_feed-none'
        end
        div 'Average Time:', class: 'right' do
          span((feed_items.process_average).to_s + ' min')
        end
        panel 'Feed Items' do
          paginated_collection(feed_items.page(params[:item_page]).per(15),
                               param_name: 'item_page', download_links: false) do
            table_for collection, sortable: true do
              column :title, sortable: false
              column(:process_length, sortable: item_ordering) do |feed_item|
                feed_item.process_length.round(2).to_s + ' min'
              end
            end
          end
        end
      end

      column do
        feeds = Feed.where('process_start is not null and process_end is not null')
        if params[:order]
          feed_order_query, feed_ordering = processing_order_string_for('feed')
          feeds = feeds.order(feed_order_query)
        else
          feed_ordering = 'item-none_feed-desc'
        end
        div 'Average Time:', class: 'right' do
          span((feeds.process_average).to_s + ' min')
        end
        panel 'Feeds' do
          paginated_collection(feeds.page(params[:feed_page]).per(15),
                               param_name: 'feed_page', download_links: false) do
            table_for collection, sortable: true do
              column :url, sortable: false
              column(:process_length, sortable: feed_ordering) do |feed|
                feed.process_length.round(2).to_s + ' min'
              end
            end
          end
        end
      end
    end
  end
end
