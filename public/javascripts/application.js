// Polino Studio application-specific JavaScript functions and classes are here

var onload_handlers = new Array();
var previousOnload = window.onload;

window.onload = function () { 
  for (var i = 0; i < onload_handlers.length; i++) 
  {
    onload_handlers[i]();
  }
  if(previousOnload) previousOnload(); 
}

/* Register function as onLoad handlerm so it will be executed each time page loads 
   Functions registered eith this method will be executed before handlers registerd
   in traditional way. In praticualr they will be executed before function, that 
   removes loadin  screen.
 */
function add_onload_handler(handler){
  onload_handlers.push(handler);
}


/* Setup sifr replacement fonts - it have its own onload listener */
function setup_sifr(){
  // TODO: Switch to ruby computed location
  var goodtime = {src: fonts_path + '/goodtime.swf'};
  var eurostile = {src: fonts_path + '/eurostile.swf'};
  sIFR.activate(goodtime, eurostile);
  sIFR.replace(goodtime,{ selector: 'span#header-studio',
	opaque: true,
	forceSingleLine: true,
	tuneHeight: -5,
	css: {'.sIFR-root': { 'color': '#bfbfbf',
	    'background-color': '#303232',
	    'font-size': '32px' 
	    }}
	});
  sIFR.replace(goodtime,{ selector: 'span#header-brand',
	opaque: true,
	forceSingleLine: true,
	tuneHeight: -5,
	css: {'.sIFR-root': { 'color': '#bfbfbf',
	    'background-color': '#303232',
	    'font-size': '26px' 
	    }}
	});
  sIFR.replace(eurostile,{ selector: '#gallery-switches ul>span',
	transparent: true,
	forceSingleLine: true,
	tuneHeight: -4,
	css: {'.sIFR-root': { 'color': '#bfbfbf',
	    'background-color': '#000000',
	    'font-size': '16px'
	    }}
	});  
  sIFR.replace(eurostile,{ selector: 'div.gallery-switch',
	forceSingleLine: true,
	transparent: true,
	tuneHeight: -4,
       	css: {'.sIFR-root': { 
	    'color': '#bfbfbf',
	    'background-color': '#000000',
	    'font-size': '16px'
	    },
	    'a': {'color': '#bfbfbf', 'text-decoration': 'none'},
	    'a:hover': {'color': '#7f7f7f'}
        }
	});  
  sIFR.initialize();
}
add_onload_handler(setup_sifr);


/* Add reflections to galery images */

function add_reflections() {
  var rimages = $$('#gallery-images img');
  for (i=0;i<rimages.length;i++) {
    Reflection.add(rimages[i], { height: 0.25, opacity : null});
  }
}
add_onload_handler(add_reflections);


/* Setup gallery scrollbar */

var scroller; //gallery scroller object wil be stored here

function setup_scrollbar() {

  /* Update images container width based on items content */
  function update_gallery_images_width() {
    var new_width = 0;
    var image_items = $$('#gallery-images > div');
    var margin = 4;
    for (i = 0 ; i < image_items.length ; i++){
      new_width += image_items[i].offsetWidth;
      new_width += margin;
    }
    document.getElementById("gallery-images").style.width = new_width + "px";
  }

  var scrollerDiv = document.getElementById("gallery-scroller");

  if (scrollerDiv){
    update_gallery_images_width();

    var imagesDiv = document.getElementById("gallery-images");
    var visibleWidth = document.getElementById("gallery").offsetWidth;
    var scrollbarWidth = document.getElementById("gallery-scrollbar-space").offsetWidth;
    var overflowSize = 4;
    
    scroller = new Scroller(scrollerDiv, imagesDiv, scrollbarWidth, visibleWidth,
			    {scrollerOffset: 0 - overflowSize,
				scrollerMinWidth: 40,
				setScrollerWidth: function(width){
				var left_width = $("gallery-scroller-left").offsetWidth;
				var right_width = $("gallery-scroller-right").offsetWidth;
				var space_width = width - left_width - right_width + 2 * overflowSize;
				$("gallery-scroller-space").style.width = space_width + "px";
				$("gallery-scroller-right").style.left = space_width + left_width + "px";
			      }});

    function stop_scrolling(event){
      scroller.cancelScrolling();
    }
    
    function start_scrolling_left(event){
      scroller.startScrollingToBeginning();
    }

    function start_scrolling_right(event){
      scroller.startScrollingToEnd();
      var el = Event.element(event)
	Event.observe("gallery-scrollbar-left", "mouseout", stop_scrolling);
    }

    function scroll_on_mousewheel(event){
      scroller.moveBy(Event.wheel(event) * (10));
      //alert("Scroll delta" + Event.wheel(event));
    }

    Event.observe("gallery-scrollbar-left", "mousedown", start_scrolling_left);
    Event.observe("gallery-scrollbar-left", "mouseup", stop_scrolling);
    
    Event.observe("gallery-scrollbar-right", "mousedown", start_scrolling_right);
    Event.observe("gallery-scrollbar-right", "mouseup", stop_scrolling);

    Event.observe("gallery-images", "mousewheel", scroll_on_mousewheel);
    Event.observe("gallery-images", "DOMMouseScroll", scroll_on_mousewheel); //firefox
  }
}
add_onload_handler(setup_scrollbar);


/* Setup gallery play/pause button */

function setup_gallery_play() {
  function play_gallery(event) {
    if (scroller.isEnd()) {
      scroller.moveToBeginning();
    }
    scroller.startScrollingToEnd({
          speed: 75, 
	  afterFinish: pause_gallery
	  });
    var el = $('gallery-play-button');
    el.className = 'playing';
    Event.stopObserving(el, 'click', play_gallery);
    Event.observe(el, 'click', pause_gallery);
    Event.observe('gallery-scrollbar-left', 'mousedown', pause_gallery);
    Event.observe('gallery-scrollbar-right', 'mousedown', pause_gallery);
    Event.observe('gallery-scroller', 'mousedown', pause_gallery);
  }

  function pause_gallery(event) {
    scroller.cancelScrolling();
    var el = $('gallery-play-button');
    el.className = '';
    Event.stopObserving(el, 'click', pause_gallery);
    Event.stopObserving('gallery-scrollbar-left', 'mousedown', pause_gallery);
    Event.stopObserving('gallery-scrollbar-right', 'mousedown', pause_gallery);
    Event.stopObserving('gallery-scroller', 'mousedown', pause_gallery);
    Event.observe(el, 'click', play_gallery);
  }

  if (document.getElementById('gallery-play-button'))
    Event.observe("gallery-play-button", "click", play_gallery);
}
add_onload_handler(setup_gallery_play);


/* Extend image description box, to match width of image */

function setup_photo_description_box(){
  var box = document.getElementById('photo-description-box');
  if (box) {
    var width = document.getElementById('photo-element').offsetWidth;
    width -= 2; //substract border
    var left = 449 - (width / 2);
    box.style.width = width + "px";
    box.style.left = left + "px";
  }
}
/*add_onload_handler(setup_photo_description_box);*/


/* Load google analytics library */

function load_ga(){
    var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
    document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
}
load_ga();


/* Setup google analytics trace code */

function setup_ga(){
  var pageTracker = _gat._getTracker("UA-4667059-1");
  pageTracker._initData();
  pageTracker._trackPageview();
}
add_onload_handler(setup_ga);

