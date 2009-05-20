/*
 * Orginal: http://adomas.org/javascript-mouse-wheel/
 * prototype extension by "Frank Monnerjahn" <themonnie@gmail.com>
 */
Object.extend(Event, {
        wheel:function (event){
                var delta = 0;
                if (!event) event = window.event;
                if (event.wheelDelta) {
                        delta = event.wheelDelta/120;
                } else if (event.detail) { delta = -event.detail/3;     }
                return Math.round(delta); //Safari Round
        }
});
/*
 * enf of extension
 */


/*
 * Check which item from controlls menu is active and set appropriate class
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


/*
 * Setup mouse move event handler for hiding nd showing buttons
 */
function setup_show_hide_buttons(trigger_element, buttons, conditions){

  /* Start from visible buttons, but with total opacity */
  var buttons_visible = false;
  for(var i = 0; i < buttons.length; i ++) {
    buttons[i].style.display = 'block';
    buttons[i].setOpacity(0);
  }

  function show_buttons(){
    buttons_visible = true;
    var effect_options = {
      from: 0.0,
      to: 1.0,
      duration: 0.5
    };
    for(var i = 0; i < buttons.length; i ++) {
      var button = buttons[i];
      new Effect.Opacity(button, effect_options);
    }
  }

  function hide_buttons(){
    buttons_visible = false;
    var effect_options = {
      from: 1.0,
      to: 0.0,
      duration: 0.5
    };
    for(var i = 0; i < buttons.length; i ++) {
      new Effect.Opacity(buttons[i], effect_options);
    }
  }

  function show_hide_buttons_on_mousemove(event){
      var mouse_x = Event.pointerX(event);
      var mouse_y = Event.pointerY(event);
      var t_offset = trigger_element.cumulativeOffset();
      var t_left = t_offset[0];
      var t_top = t_offset[1];
      var t_right = t_left + trigger_element.getWidth();
      var t_bottom = t_top + trigger_element.getHeight();

      if((mouse_x > t_left) && (mouse_x < t_right) &&
	 (mouse_y > t_top) && (mouse_y < t_bottom)) {
	/* Mouse in trigger_element box */
	if(!buttons_visible) show_buttons();
      } else {
	/* Mouse out of trigger_element box */
	if(buttons_visible) hide_buttons();
      }
  }

  Event.observe(document, 'mousemove', show_hide_buttons_on_mousemove);
}


/*
 * Setup galleries list scroll controlls
 */
var scroll_banners_down_handler;
var scroll_banners_up_handler;

function setup_galleries_list_scroll(){
  var galleries_div = $('galleries');
  if(galleries_div){
    /* Turn off html scrollbars */
    galleries_div.style.overflow = 'hidden';
    galleries_div.scrollLeft = 0;
    galleries_div.scrollTop = 0;

    var banners = galleries_div.select('.gallery_banner');
    if(banners.length > 3) {
      var button_up = $('galleries_scroll_button_up');
      var button_down = $('galleries_scroll_button_down');

      /* Switch all banners position to absolute, and make in unslectable */
      for(var i = 0; i < banners.length; i ++){
	banners[i].style.position = 'absolute';
	banners[i].style.left = '0px';
	banners[i].style.top = (i * 150) + 'px';
	banners[i].unslectable = true;
	banners[i].onselectstart = banners[i].onmousedown = function(){return false;};
      }

      var effect_duration = 0.5;
      var banners_offset = 0;

      var in_scroll_up = false;
      var in_scroll_down = false;


      function queue_scroll_effects(scroll_effects, effect_setup_handler){
	var queue = Effect.Queues.get('galleries_scroll');
	new Effect.Parallel(scroll_effects,
	  {duration: effect_duration,
	   queue: {scope: 'galleries_scroll', position: 'end', limit: 2},
	   afterSetup: effect_setup_handler
	   });
      }

      function scroll_down(){
	queue_scroll_effects([], function(effect){
	  var scroll_effects = new Array(4);
	  for(var i = 0; i < 4; i ++){
	    var banner_index = banners_offset + i;
	    if(banner_index >= banners.length) {
	      banner_index -= banners.length;
	    }
	    var e_options = {x: 0, y: -150, mode: 'relative', sync: true };
	    if(i == 3) {
	      e_options.beforeSetup = function(m_effect){
	        m_effect.element.setStyle({top: '450px'});
	      };
	    }
	    scroll_effects[i] = new Effect.Move(banners[banner_index], e_options);
	  };
	  banners_offset += 1;
	  if(banners_offset >= banners.length) {
	    banners_offset -= banners.length;
	  }
	  effect.effects = scroll_effects;
	});
      }

      function scroll_up(){
	queue_scroll_effects([], function(effect){
	  var scroll_effects = new Array(4);
	  for(var i = 0; i < 4; i ++){
	    var banner_index = banners_offset + i - 1;
	    if(banner_index < 0) {
	      banner_index += banners.length;
	    } else if(banner_index >= banners.length) {
	      banner_index -= banners.length;
	    }
	    var e_options = {x: 0, y: 150, mode: 'relative', sync: true};
	    if(i == 0) {
	      e_options.beforeSetup = function(m_effect){
		m_effect.element.setStyle({top: '-150px'});
	      };
	    }
	    scroll_effects[i] = new Effect.Move(banners[banner_index], e_options);
	  };
	  banners_offset -= 1;
	  if(banners_offset < 0) {
	    banners_offset += banners.length;
	  }
	  effect.effects = scroll_effects;
	});
      }

      scroll_banners_down_handler = function(){
	if(in_scroll_down){
	  scroll_down();
	  setTimeout(scroll_banners_down_handler, effect_duration * 1000);
	}
      };

      scroll_banners_up_handler = function(){
	if(in_scroll_up){
	  scroll_up();
	  setTimeout(scroll_banners_up_handler, effect_duration * 1000);
	}
      };

      button_down.observe('mousedown', function(){
	in_scroll_down=true; scroll_banners_down_handler();});
      button_down.observe('mouseup', function(){in_scroll_down=false;});
      button_down.observe('mouseout', function(){in_scroll_down=false;});

      button_up.observe('mousedown', function(){
	in_scroll_up=true; scroll_banners_up_handler();});
      button_up.observe('mouseup', function(){in_scroll_up=false;});
      button_up.observe('mouseout', function(){in_scroll_up=false;});

      function scroll_on_mousewheel(event) {
	var wheel_offset = Event.wheel(event);
	if(wheel_offset < 0){
	  scroll_down();
	} else if(wheel_offset > 0){
	  scroll_up();
	}
      }

      galleries_div.observe("mousewheel", scroll_on_mousewheel);
      galleries_div.observe("DOMMouseScroll", scroll_on_mousewheel); //firefox

      setup_show_hide_buttons(galleries_div, [button_up, button_down]);
    }
  }
}
Event.observe(window, 'load', setup_galleries_list_scroll);


/*
 * Scroll efect used to scroll galleries photos and topic content
 */
var ScrollEffect = function(element){
  var options = Object.extend({
    speed: 400, /* sppeed in pixels per second */
    direction: 'horizontal', /* can be horizontal, or vertical */
    transition: Effect.Transitions.linear
  }, arguments[1] || {});
  var start_position;
  var end_position;
  var viewport_size;
  var maximum_position;
  if(options.direction == 'horizontal'){
    start_position = element.scrollLeft;
    viewport_size = element.offsetWidth;
    maximum_position = element.scrollWidth - viewport_size;
  } else {
    start_position = element.scrollTop;
    viewport_size = element.offsetHeight;
    maximum_position = element.scrollHeight - viewport_size;
  }
  if(options.offset == 'beginning') {
    end_position = 0;
  } else if(options.offset == 'finish') {
    end_position = maximum_position;
  } else {
    end_position = start_position + options.offset;
    if(end_position < 0){
      end_position = 0;
    } else if(end_position > maximum_position){
      end_position = maximum_position;
    }
  }
  options.offset = end_position - start_position;
  options.duration = 1.0 * options.offset / options.speed;
  if(options.duration < 0) options.duration = -options.duration;
  var scroll_handler;
  if(options.direction == 'horizontal'){
    scroll_handler = function(p){element.scrollLeft = p.round();};
  } else {
    scroll_handler = function(p){element.scrollTop = p.round();};
  }
  return new Effect.Tween(element, start_position, end_position,
			  options, scroll_handler);
};


/*
 * Setup gallery photos list scroll controlls
 */
function setup_gallery_photos_scroll(){
  var gallery_viewport = $('gallery_viewport');
  if(gallery_viewport){

    /* Turn off html scrollbars */
    gallery_viewport.setStyle({overflow: 'hidden'});
    var gallery_body = $('gallery_body');
    gallery_body.setStyle({height: '450px'});
    var photos_width = gallery_body.offsetWidth;
    var photos_viewport_width = gallery_viewport.offsetWidth;

    if(photos_width > 800){
      var scroll_efect;

      function start_scroll_left(){
	scroll_efect = ScrollEffect(gallery_viewport, {offset: 'beginning'});
      }

      function start_scroll_right(){
	scroll_efect = ScrollEffect(gallery_viewport, {offset: 'finish'});
      }

      function start_scroll_on_wheel(event){
	var scroll_offset = -(Event.wheel(event) * 40);
	if(!scroll_efect || (scroll_efect.state != 'running')) {
	  scroll_efect = ScrollEffect(gallery_viewport, {offset: scroll_offset});
	}
      }

      function stop_scroll(){
	if(scroll_efect) scroll_efect.cancel();
      }


      var button_left = $('gallery_scroll_button_left');
      var button_right = $('gallery_scroll_button_right');

      button_left.observe('mousedown', start_scroll_left);
      button_left.observe('mouseup', stop_scroll);
      button_left.observe('mouseout', stop_scroll);

      button_right.observe('mousedown', start_scroll_right);
      button_right.observe('mouseup', stop_scroll);
      button_right.observe('mouseout', stop_scroll);

      gallery_viewport.observe("mousewheel", start_scroll_on_wheel);
      gallery_viewport.observe("DOMMouseScroll", start_scroll_on_wheel); //firefox

      setup_show_hide_buttons(gallery_viewport, [button_left, button_right]);
    }
  }
}
Event.observe(window, 'load', setup_gallery_photos_scroll);


/*
 * Setup topic scroll controlls
 */
function setup_topic_scroll(){
  var topic_viewport = $('topic_viewport');
  if(topic_viewport){

    /* Turn off html scrollbars */
    topic_viewport.setStyle({overflow: 'hidden'});
    var topic_viewport_height = topic_viewport.offsetHeight;

    if(topic_viewport.scrollHeight > 450){
      var scroll_efect;

      function start_scroll_up(){
	scroll_efect = ScrollEffect(topic_viewport,
				    {offset: 'beginning', direction: 'vertical'});
      }

      function start_scroll_down(){
	scroll_efect = ScrollEffect(topic_viewport,
				    {offset: 'finish', direction: 'vertical'});
      }

      function start_scroll_on_wheel(event){
	var scroll_offset = -(Event.wheel(event) * 10);
	if(!scroll_efect || (scroll_efect.state != 'running')) {
	  scroll_efect = ScrollEffect(gallery_viewport,
				      {offset: scroll_offset,
				       mode: 'vertical'});
	}
      }

      function stop_scroll(){
	if(scroll_efect) scroll_efect.cancel();
      }

      var button_up = $('topic_scroll_button_up');
      var button_down = $('topic_scroll_button_down');

      button_up.observe('mousedown', start_scroll_up);
      button_up.observe('mouseup', stop_scroll);
      button_up.observe('mouseout', stop_scroll);

      button_down.observe('mousedown', start_scroll_down);
      button_down.observe('mouseup', stop_scroll);
      button_down.observe('mouseout', stop_scroll);

      topic_viewport.observe("mousewheel", start_scroll_on_wheel);
      topic_viewport.observe("DOMMouseScroll", start_scroll_on_wheel); //firefox

      setup_show_hide_buttons(topic_viewport, [button_up, button_down]);
    }
  }
}
Event.observe(window, 'load', setup_topic_scroll);
