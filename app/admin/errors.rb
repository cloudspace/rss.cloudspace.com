ActiveAdmin.register WorkerError, as: 'Errors' do
  menu priority: 3

  index download_links: false do
    column :id
    column :element_type
    column :'Element Id'
    column :message
    column :created_at
  end
end
