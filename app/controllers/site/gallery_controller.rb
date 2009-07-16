class Site::GalleryController < Site::BaseController

  setup_controller_context( [:gallery],
                            Proc.new { |site, context| [site.galleries.find_by_name(context)] },
                            Proc.new { |vals| vals[0].name },
                            Proc.new { |site| site.galleries.map{|g| g.name} }
                            )

end
