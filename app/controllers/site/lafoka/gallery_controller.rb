class Site::Lafoka::GalleryController < Site::GalleryController

  SINGLE_PHOTO_MIN_WIDTH = 435 # Photos that are wider than this value are displayed on single page

  acts_as_page( :page,
                :context_iterator => Proc.new {|vals| 1..pages_count(vals[0])},
                :sitemap_info =>
                { :priority => '0.8',
                  :changefreq => 'daily' }
                )

  # Return total number of pages for gallery
  def self.pages_count(gallery)
    dummy_controller = self.new
    dummy_controller.instance_eval do
      @gallery = gallery
      @page_num = 1
      setup_page_info
      @page_count
    end
  end

  def page
    @page_num = params[:action_context].to_i || 1 # page number starting from 1
    setup_page_info
    render
  end

  protected

  # Setup gallery page information. Requires @gallery and @page_num variable, 
  # and sets @page_count and @page_pgotos attributes
  def setup_page_info
    @page_count = 0
    @page_photos = []
    photos = @gallery.gallery_items.find(:all, :conditions => { :type => GalleryPhoto.name })
    photos = photos.map{|p| p.photo}
    while photos.size > 0
      photo_left = photos.shift
      photo_right = nil
      if photo_left.image_width <= SINGLE_PHOTO_MIN_WIDTH
        photo_right = photos.shift
      end
      if photo_right and photo_right.image_width > SINGLE_PHOTO_MIN_WIDTH
        photos.unshift(photo_right)
        photo_right = nil
      end
      @page_count += 1
      if @page_count == @page_num
        @page_photos << photo_left
        @page_photos << photo_right if photo_right
      end
    end
    @page_count = 1 if @page_count == 0    
  end

end 
