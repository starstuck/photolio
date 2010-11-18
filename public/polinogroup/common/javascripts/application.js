$(document).ready(function(){
  var galleryController;

  function onContentChange(){
    var galleryJContext = $('#content-inner').find('#gallery-photos-viewport');
    if ( galleryJContext.length > 0 ){
      galleryController = new GalleryController( galleryJContext.get(0) );
      if (window.console) console.log('Galley controller initialized');
    } else {
      galleryController = null; //Hint for garbage collector
    }
  };

  $('#content-inner').bind('change', onContentChange);
  onContentChange();
});