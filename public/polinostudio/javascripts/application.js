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
   removes loading screen.
 */
function add_onload_handler(handler){
  onload_handlers.push(handler);
}


/* Add reflections to galery images */

function add_reflections(){
  var rimages = $$('#gallery_photos img');
  for (i=0;i<rimages.length;i++) {
    Reflection.add(rimages[i], { height: 0.25, opacity : null});
  }
}
add_onload_handler(add_reflections);


/* Setup gallery scrollbar */

var scroller; //gallery scroller object wil be stored here

function setup_scrollbar() {

  var scrollerDiv = document.getElementById("gallery_scroller");

  if (scrollerDiv){

    /* Turn off default browser scroller, and enable custom one */
    document.getElementById("gallery_photos_viewport").style.overflow = "hidden";
    document.getElementById("gallery_scrollbar").style.display = "block";

    var imagesDiv = document.getElementById("gallery_photos");
    var visibleWidth = document.getElementById("gallery_photos_viewport").offsetWidth;
    var scrollbarWidth = document.getElementById("gallery_scrollbar_space").offsetWidth;
    var overflowSize = 4;

    // alert('Started with scroll position: ' + document.getElementById("gallery_photos_viewport").scrollLeft);

    scroller = new Scroller(scrollerDiv, imagesDiv, scrollbarWidth, visibleWidth,
			    {scrollerOffset: 0 - overflowSize,
				scrollerMinWidth: 40,
				setScrollerWidth: function(width){
				var left_width = $("gallery_scroller_left").offsetWidth;
				var right_width = $("gallery_scroller_right").offsetWidth;
				var space_width = width - left_width - right_width + 2 * overflowSize;
				$("gallery_scroller_space").style.width = space_width + "px";
				$("gallery_scroller_right").style.left = space_width + left_width + "px";
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
	Event.observe("gallery_scrollbar_left", "mouseout", stop_scrolling);
    }

    function scroll_on_mousewheel(event){
      scroller.moveBy(Event.wheel(event) * (10));
    }

    Event.observe("gallery_scrollbar_left", "mousedown", start_scrolling_left);
    Event.observe("gallery_scrollbar_left", "mouseup", stop_scrolling);

    Event.observe("gallery_scrollbar_right", "mousedown", start_scrolling_right);
    Event.observe("gallery_scrollbar_right", "mouseup", stop_scrolling);

    Event.observe("gallery_photos", "mousewheel", scroll_on_mousewheel);
    Event.observe("gallery_photos", "DOMMouseScroll", scroll_on_mousewheel); //firefox
  }
}
add_onload_handler(setup_scrollbar);


/* Setup gallery play/pause button */

function setup_gallery_controlls() {
  function play_gallery(event) {
    if (scroller.isEnd()) {
      scroller.moveToBeginning();
    }
    scroller.startScrollingToEnd({
          speed: 75,
	  afterFinish: pause_gallery
	  });
    var el = $('gallery_play_button');
    el.className = 'playing';
    Event.stopObserving(el, 'click', play_gallery);
    Event.observe(el, 'click', pause_gallery);
    Event.observe('gallery_scrollbar_left', 'mousedown', pause_gallery);
    Event.observe('gallery_scrollbar_right', 'mousedown', pause_gallery);
    Event.observe('gallery_scroller', 'mousedown', pause_gallery);
  }

  function pause_gallery(event) {
    scroller.cancelScrolling();
    var el = $('gallery_play_button');
    el.className = '';
    Event.stopObserving(el, 'click', pause_gallery);
    Event.stopObserving('gallery_scrollbar_left', 'mousedown', pause_gallery);
    Event.stopObserving('gallery_scrollbar_right', 'mousedown', pause_gallery);
    Event.stopObserving('gallery_scroller', 'mousedown', pause_gallery);
    Event.observe(el, 'click', play_gallery);
  }

  var controlsDiv = document.getElementById('gallery_controls');
  if (controlsDiv) {
    if (document.getElementById('gallery_play_button'))
      Event.observe("gallery_play_button", "click", play_gallery);
    controlsDiv.style.display = 'block';
  }
}
add_onload_handler(setup_gallery_controlls);


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


/*
 * Library functions called from html
 */

/* Go back in history. If page is first time called, return true */
function go_back(){
  if(document.referrer&&document.referrer!=""){
    history.go(-1);
    return false;
  }else{
    return true;
  }
}
