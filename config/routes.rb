ActionController::Routing::Routes.draw do |map|

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Map resources for admin screens
  map.namespace :admin do |admin|
    admin.root :controller => 'admin/base'
    admin.resources :users, :member => ['change_password', 'reset_password']
    admin.resource :session, :member => ['delete']
    admin.resources(:sites, 
                    :member => ['layout', 
                                'layout_gallery_photos_partial',
                                'layout_unassigned_photos_partial',
                                'layout_add_gallery_photo',
                                'layout_remove_gallery_photo',
                                'layout_add_gallery_separator',
                                'layout_remove_gallery_separator',
                                'publish'] 
                    ) do |site|
      site.resources :assets
      site.resources :galleries
      site.resources :photos do |photo|
        photo.resources :photo_keywords, :as => 'keywords', :name_prefix => 'admin_site_'
        photo.resources :photo_participants, :as => 'participants', :name_prefix => 'admin_site_'
      end
      site.resources :topics
    end
  end


  map.show_site_gallery(':site_name/gallery/:gallery_name.:format',
                        :controller => 'site/gallery',
                        :action => 'dispatch',
                        :method_name => 'show')
  map.dispatch_site_gallery(':site_name/gallery/:gallery_name/:method_name.:format',
                            :controller => 'site/gallery',
                            :action => 'dispatch')

  map.show_site_topic(':site_name/topic/:topic_name.:format',
                      :controller => 'site/topic',
                      :action => 'dispatch',
                      :method_name => 'show')
  map.dispatch_site_topic(':site_name/topic/:topic_name/:method_name.:format',
                            :controller => 'site/topic',
                            :action => 'dispatch')

  map.show_site_photo(':site_name/photo/:photo_id.:format',
                      :controller => 'site/photo',
                      :action => 'dispatch',
                      :method_name => 'show')
  map.dispatch_site_photo(':site_name/photo/:photo_id/:method_name.:format',
                            :controller => 'site/photo',
                            :action => 'dispatch')

  map.show_site(':site_name/', 
                :controller => 'site/site',
                :action => 'dispatch',
                :method_name => 'show',
                :format => 'html')
  map.dispatch_site(':site_name/:method_name.:format', 
                    :controller => 'site/site',
                    :action => 'dispatch')
  

  # Map public views published, live
#  for controller, actions, id_method in [['site', ['show', 'index', 'sitemap'], ''],
#                                         ['galleries', ['show'], ''],
#                                         ['gallery', ['show'], 'name'],
#                                         ['photo', ['show'], 'id'],
#                                         ['topic', ['show'], 'name']
#                                        ]
#    for action in actions
#      controller_name_part = controller != 'site' ? "_#{controller}" : ""
#      controller_path_part = controller != 'site' ? "/#{controller}" : ""
#      identifier_path_part = id_method != "" ? "/:#{controller}_#{id_method}" : ""
#      if controller == 'site'
#        if action == 'show'
#          file_path_part = '/index'
#        elsif action == 'index'
#          file_path_part = ''
#        else
#          file_path_part = "/#{action}"
#        end
#      else
#        file_path_part = action != 'show' ? "/#{action}" : ""
#      end
#      r_name = "#{action}_site#{controller_name_part}"
#      r_path = ":site_name#{controller_path_part}#{identifier_path_part}#{file_path_part}.:format"
#      r_params = {
#        :controller => "site/#{controller}",
#        :action => action }             
#      map.send(r_name, r_path, r_params)
#    end
#  end

  # Redirects for easy address entering
  map.root :controller => 'admin/base', :action => 'index'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
