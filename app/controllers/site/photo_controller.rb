class Site::PhotoController < Site::BaseController
  
  setup_controller_context( [:photo],
                            Proc.new { |site, context| [site.photos.find(context)] },
                            Proc.new { |vals| vals[0].id },
                            Proc.new do |site| 
                              hidden_photo_ids = site.unassigned_photos.map{|x| x.id}
                              site.photos.reject{ |p|
                                hidden_photo_ids.include? p.id
                              }.map{|p| p.id}
                            end
                            )

end
