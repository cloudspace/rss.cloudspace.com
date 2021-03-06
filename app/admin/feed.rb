ActiveAdmin.register Feed, namespace: :admin do
  menu false

  controller do
    def destroy
      Feed.find(params[:id]).destroy
      redirect_to admin_root_path
    end
  end

  show do
    attributes_table do
      row :name
      row :site_url
      row :scheduled
      row :processing
      row :process_start
      row :process_end
      row :process_killed
      row :parse_backoff_level
      row :last_parsed_at
      row :next_parse_at
      row :url
      row :errors do |feed|
        WorkerError.where(element: feed).group_by(&:message).map do |error, feeds|
          label_tag(feeds.count.to_s + ' - ' + error)
        end.join('<br />').html_safe
      end
    end
  end
end
