module ActiveAdmin::ViewsHelper
  def processing_order_string_for(type)
    other = (type == 'item') ? 'feed' : 'item'
    object_string = params[:order].split('_').select{ |x| x.include?(type)}[0]

    order = object_string.split('-')[1]
    object_string.gsub!(order, order == 'desc' ? 'asc' : 'desc')
    order = 'desc' if order == 'none'
    
    return ['process_end-process_start '+order, 
      params[:order].split('_').select{ |x| x.include?(other)}[0]+'_'+object_string]
  end
end
