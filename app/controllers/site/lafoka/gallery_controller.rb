class Site::Lafoka::GalleryController < Site::GalleryController

  acts_as_page( :page,
                :context_iterator => Proc.new {|vals| 1..max_page_number(vals[0])},
                :sitemap_info =>
                { :priority => '0.8',
                  :changefreq => 'daily' }
                )

  def page    
    @page_num = params[:action_context] || 1
    render
  end

  # Calculate total number of pages for gallery
  def self.max_page_number(gallery)
    3
  end

end 
