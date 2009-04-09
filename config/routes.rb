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

  # Map public views published, live, branded  and unbranded for both cases
  for controller, actions, id_method in [['site', ['index', 'sitemap'], 'name'],
                                         ['gallery', ['show'], 'name'],
                                         ['photo', ['show'], 'id'],
                                         ['topic', ['show'], 'name']
                                        ]
    for action in actions
      controller_name_part = controller != 'site' ? "_#{controller}" : ""
      controller_path_part = controller != 'site' ? "#{controller}/" : ""
      map.send("#{action}_live_studio#{controller_name_part}", 
               "live/#{controller_path_part}:#{controller}_#{id_method}.:format",
               :controller => controller,
               :action => action,
               :site_name => 'studio',
               :published => false
               )             
      map.send("#{action}_published_studio#{controller_name_part}", 
               "#{controller_path_part}:#{controller}_#{id_method}.:format",
               :controller => controller,
               :action => action,
               :site_name => 'studio',
               :published => true
               )             
      map.send("#{action}_live_brand_site#{controller_name_part}", 
               ":site_brand/:site_name/#{controller_path_part}:#{controller}_#{id_method}.:format",
               :controller => controller,
               :action => action,
               :site_brand => /(#{Site::BRANDS.join('|')})/,
               :published => false
               )             
      map.send("#{action}_published_brand_site#{controller_name_part}", 
               "live/:site_brand/:site_name/#{controller_path_part}:#{controller}_#{id_method}.:format",
               :controller => controller,
               :action => action,
               :site_brand => /(#{Site::BRANDS.join('|')})/,
               :published => true
               )             
    end
  end

  # Map resources for admin screens
  map.namespace :admin do |admin|
    admin.root :controller => 'admin_base'
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
      site.resources :galleries
      site.resources :photos do |photo|
        photo.resources :photo_keywords, :as => 'keywords', :name_prefix => 'admin_site_'
        photo.resources :photo_participants, :as => 'participants', :name_prefix => 'admin_site_'
      end
      site.resources :topics
    end
  end
  
  # Redirects for easy address entering
  map.connect 'live', :controller => 'site', :action => 'index', :site_name => 'studio', :published => false
  map.root :controller => 'site', :action => 'index', :site_name => 'studio', :published => true

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
