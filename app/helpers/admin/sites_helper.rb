module Admin::SitesHelper

  # Javascript for use in draggable_element invocation, as revert parameter
  # In case of succesfull dorp, it stops revertin. IF drop does not activate 
  # any dropable, draged element is revertd
  def draggable_revert_js()
    'function(element){ if(!Droppables.last_active){return true} else{return false};}'
  end

  # Generate function which make ajax call to update element, in case of
  # succesfull drom
  # Perfect for use as onEnd argument for draggable_element invocation
  def draggable_on_end_js(options={})
    options[:loading] ||= "Element.update('#{options[:update]}', '<td style=\"width: 100px;\">#{loading_tag}</td>')"
    extra_conditions = options.delete(:conditions)
    conditions = 'Droppables.last_active'
    conditions = '(#{conditions} && (#{extra_conditions})' if extra_conditions
    %(function(element){if(#{conditions}){#{remote_function(options)}}})
  end
  
end
