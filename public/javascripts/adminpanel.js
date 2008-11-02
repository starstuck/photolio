
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
