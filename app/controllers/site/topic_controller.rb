class Site::TopicController < Site::BaseController

  setup_controller_context( [:topic],
                            Proc.new { |site, context| [site.topics.find_by_name(context)] },
                            Proc.new { |vals| vals[0].name },
                            Proc.new { |site| site.topics.map{|g| g.name} }
                            )

end
