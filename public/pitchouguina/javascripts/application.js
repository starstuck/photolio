/*
 * Chech which item from controlls menu is active and set appropriate class
 */
function activate_active_menu_link(){
  var atags = $$('.controlls_menu a');
  for(var i=0; i < atags.length; i += 1){
    var atag = atags[i];
    if( document.URL.match(atag.href) ){
      atag.className += ' active';
    }
  }
}
Event.observe(window, 'load', activate_active_menu_link);