class GalleryController < ApplicationController

  before_filter :setup_context

  def show
    @galleries = @site.galleries.reject{ |g| not g.display_in_index }.sort do |x, y|
      # Sort galeries like numbers if name starts from digits (2 is lower then 10)
      xn = x.name
      yn = y.name
      x_is_num = (xn.to_i != 0 or xn[0] == '0')
      y_is_num = (yn.to_i != 0 or yn[0] == '0')
      
      result = begin
                 if x_is_num and y_is_num
                   xn.to_i <=> yn.to_i
                 elsif x_is_num
                   -1
                 elsif y_is_num
                   1
                 else
                   nil
                 end
               end
          
      if result and result != 0
        result
      else
        xn <=> yn #falback to string comparision
      end        
    end
    @menu_items = @site.topics.find(:all, :conditions => 'display_in_menu <> 0' )

    respond_to do |format|
      format.html 
      format.parthtml { render :template => 'gallery/show.html.erb', :layout => false }
    end
  end

  private

  def setup_context
    @site = Site.find( :first, :conditions => { 'name' => params[:site_name] } )
    @gallery = @site.galleries.find( :first, :conditions => { 'name' => params[:gallery_name] } )
  end

end
