ActiveAdmin.register WorkerError, as: 'Errors' do
  menu priority: 3

  filter :element_type
  filter :element_id, label: 'Element Id'
  filter :message
  filter :created_at

  index download_links: false do
    column :element_type
    column(:'Element Id') { |error| error.element_id }
    column :message
    column :created_at
  end
end
