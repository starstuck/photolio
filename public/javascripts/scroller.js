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
			if (window.opera) delta = -delta;
		} else if (event.detail) { delta = -event.detail/3;	}
		return Math.round(delta); //Safari Round
	}
});
/*
 * enf of extension 
 */ 


//Scroller object that scroll content based on scrollbar drag

var Scroller = Class.create();
Scroller.prototype = {

 initialize: function(scrollerEl, contentEl, scrollbarWidth, viewportWidth, overrides){
    /* Store required parameters */
    this.scrollerEl = scrollerEl;
    this.contentEl = contentEl;
    this.scrollbarWidth = scrollbarWidth;
    this.viewportWidth = viewportWidth;

    /* Set default attriutes */
    this.scrollerMinWidth = 10;
    this.scrollerOffset = 0;//How much scroller is schifted to coordinates 0 point

    /* Allow overwirte any attribute or method */
    Object.extend(this, overrides);

    /* Compute additional paramters */
    this.contentWidth = contentEl.offsetWidth;
    this.scrollerWidth = this.viewportWidth * this.scrollbarWidth / this.contentWidth
    this.scrollerDistance = Math.round(this.scrollbarWidth - this.scrollerWidth);
    this.contentDistance = this.contentWidth - this.viewportWidth;
    if (this.scrollerWidth > this.viewportWidth) {
      this.scrollerWidth = this.scrollbarWidth
    }
    if (this.scrollerWidth < this.scrollerMinWidth) {
      this.scrollerWidth = this.scrollerMinWidth;
    }
    
    this._setup();
  },
 
  _setup: function() {
    this.setScrollerWidth(this.scrollerWidth);
    this.setScrollerPos(0);
    this.setContentPos(0);

    var scrl_y_loc = this.scrollerEl.offsetTop;
    var scrl_x_min = this.scrollerOffset;
    var scrl_x_max = this.scrollerOffset + this.scrollerDistance;
    
    this.draggable = new Draggable(this.scrollerEl, {
      snap: function(x, y){
	  if(x < scrl_x_min) x = scrl_x_min;
	  if(x > scrl_x_max) x = scrl_x_max;
	  return [x, scrl_y_loc];
	},
      onDrag: this.drag.bind(this)
      });
  },
 
 setScrollerWidth: function(width){
    this.scrollerEl.style.width = Math.round(width) + "px";
  },

 getScrollerPos: function(){
    return this.scrollerEl.offsetLeft - this.scrollerOffset;
  },

 /* Position mus be already check if it is valid */
 setScrollerPos: function(newPos){
    this.scrollerEl.style.left = Math.round(newPos + this.scrollerOffset) + "px";    
  },

 getContentPos: function(){
    return this.contentEl.offsetLeft;
  },

 setContentPos: function(newPos){
    this.contentEl.style.left = Math.round(newPos) + "px";
  },

 getContnetPosForScrollerPos: function(scrollPos){
    return 0 - (scrollPos * this.contentDistance / this.scrollerDistance);
  },

 getScrollerPosForContentPos: function(contentPos){
    return 0 - (contentPos * this.scrollerDistance / this.contentDistance);
  },

 setContentAndScrollerPos: function(contentPos){
    this.setContentPos(contentPos);
    this.setScrollerPos(this.getScrollerPosForContentPos(contentPos));
  },

 moveToBeginning: function(){
    this.setContentAndScrollerPos(0);
  },

 moveToEnd: function(){
    this.setContentAndScrollerPos(0 - this.contentDistance);
  },

 moveBy: function(delta){
    var newPos  = this.getContentPos() + delta;
    if(newPos > 0) newPos = 0;
    if(newPos < -this.contentDistance) newPos = (0 - this.contentDistance);
    this.setContentAndScrollerPos(newPos);
  },

 drag: function(x, y){
    if(this.scrollEffect) this.cancelScrolling();
    var sPos = this.getScrollerPos();
    this.setContentPos(this.getContnetPosForScrollerPos(sPos));
  },


 /* Start scrolling to specyfic location.
  * Location is measured in content pixels, 
  * speed is number of pixels per second
  */
 startScrollingTo: function(dest, options){
    if(this.scrollEffect) this.cancelScrolling();
    var options = Object.extend({
      target: dest,
      speed: 800,
      fps: 30},
      arguments[1] || { });
    if(options.target != this.getContentPos()){
      if (options.target < this.getContentPos()) options.speed = 0 - options.speed; 
      this.scrollEffect = new ScrollEffect(this, options);
    }
  },

 startScrollingToBeginning: function(){
    this.startScrollingTo(0);
  },

 startScrollingToBeginning: function(options){
    this.startScrollingTo(0, options);
  },

 startScrollingToEnd: function(){
    this.startScrollingTo(0 - this.contentDistance);
  },

 startScrollingToEnd: function(options){
    this.startScrollingTo(0 - this.contentDistance, options);
  },

 /* Stop active scrolling process */
 cancelScrolling: function(){
    if(this.scrollEffect) {
      this.scrollEffect.cancel();
      this.scrollEffect = null;
    }
  },

 /* True if scroll is at beginning */
 isBeginning: function(){
    if(this.getContentPos() == 0) return 1;
    else return 0;
  },

 /* True if scroll is at the end */
 isEnd: function(){
    if(this.getContentPos() == 0 - this.contentDistance) return 1;
    else return 0;
  }

};


/* Scroll efect is used for smoothly scrolling scroller content and scrollbar */
ScrollEffect = Class.create(Effect.Base, {
  initialize: function(element){
      this.element = $(element);
      if (!this.element) throw(Effect._elementDoesNotExistError);
      var options = Object.extend({
	speed: 100,
	    transition: Effect.Transitions.linear 
	}, arguments[1] || { });

      this.originalPos = this.element.getContentPos();
      /* Update efect lenght based on number of steps and distance to travel */
      var distance = options.target - this.originalPos;
      options.duration = distance / options.speed;
      options.to = options.duration

      this.start(options);
    },
     
  update: function(position){
      this.element.setContentAndScrollerPos(this.originalPos + position * this.options.speed);
    }
  });

