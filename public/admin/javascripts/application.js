// Setup rototype to calculate scrolls offsets when calculating position
// Used by draggable in layout panel
// WARNING: It cause serious problems on firefox
Position.includeScrollOffsets = true;


// Setup listener, which resize content frame on window resize
function resize_content_on_window_resize(event){
  var window_height;
  if( typeof( window.innerHeight ) == 'number' ) {
    //Non-IE
    window_height = window.innerHeight;
  } else if( document.documentElement && ( document.documentElement.clientHeight ) ) {
    // IE 6+
    window_height = document.documentElement.clientWidth;
  }
  var updated_content_height = window_height - 94;
  if(updated_content_height < 570){
    updated_content_height = 570;
  }
  $('content').style.height = updated_content_height + 'px';
  $('content_scrollframe').style.height = (updated_content_height - 15) + 'px';
}
Event.observe(document.onresize ? document : window, "resize", resize_content_on_window_resize);
Event.observe(window, "load", resize_content_on_window_resize);

/*
 * Functions called from html
 */

// Add keyword form edit tag in form, just above element
var last_photo_keyword_tag_index = 0;
function add_photo_keyword_tag(element, index){
  if(index > last_photo_keyword_tag_index){
    last_photo_keyword_tag_index = index;
  }
  index = last_photo_keyword_tag_index
  var content = '<input id="photo_keywords_' +
    index + '_name" name="photo[keywords][' +
    index + '][name]" size="46" type="text" value="" /><br />';
  Element.insert(element, {before: content});
  last_photo_keyword_tag_index += 1;
}


// Add photo participantt edit tag in form, just above element
var last_photo_participant_tag_index = 0;
function add_photo_participant_tag(element, index){
  if(index > last_photo_keyword_tag_index){
    last_photo_keyword_tag_index = index;
  }
  index = last_photo_keyword_tag_index
  var content =
    '<input id="photo_participants_' +
    index + '_name" name="photo[participants][' +
    index + '][role]" size="15" type="text" value="" />: ' +
    '<input id="photo_participants_' +
    index + '_name" name="photo[participants][' +
    index + '][name]" size="26" type="text" value="" />' +
    '<br />';
  Element.insert(element, {before: content});
  last_photo_keyword_tag_index += 1;
}


function drag_photo_copy(event){
  var element = Event.element(event);
  var photo_id = element.id.split('_')[1];
  var clone = element.cloneNode(false);
  clone.id = element.id + '_copy';
  clone.style.position = 'absolute';
  element.parentNode.appendChild(clone);
  $(clone).clonePosition(element);
  $(clone).addClassName('copy');

  var draggable = new Draggable( clone.id, {
    revert:function(element){
      if(!Droppables.last_active) {
	return true;
      } else {
	return false;
      }
    },
    scroll:'content_scrollframe'
  });
  /*draggable.startDrag();*/
}
