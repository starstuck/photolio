class Site::PhotoController < Site::BaseController
  
  setup_controller_context( [:photo],
                            Proc.new { |site, context| [site.photos.find_by_id(context)] },
                            Proc.new { |vals| vals[0].id },
                            Proc.new do |site| 
                              hidden_photo_ids = site.unassigned_photos.map{|x| x.id}
                              site.photos.reject{ |p|
                                not hidden_photo_ids.include? p.id
                              }.map{|p| p.id}
                            end
                            )

end
