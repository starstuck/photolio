
function GalleryController(element){
  this.initialize.apply(this, arguments);
};


/* TODO: extract generic custom scroll component,
 *   which is extended by custom dynamic scroll
 */
GalleryController.prototype = $.extend(GalleryController.prototype, {

  scrollSeparatorLength: 100,
  animationSpeed: 100,

  initialize: function(element){
    var t = this;
    t.context = element;
    t.photosEl = $('#gallery-photos').get(0);
    t.isInDrag = false;
    t.isInSectionSwitchAnimation = false;
    t.updateViewportWidth();
    t.initializeScroller();
    t.context.style.overflow = 'hidden';
    t.initializeReflections();
  },

  initializeScroller:function(){
    var t = this;
    t.scrollbar = $('<div class="ui-scrollbar"><div class="ui-scroller"><div class="ui-scroller-inner"></div></div><div class="ui-scrollbar-extra"></div></div>');
    t.scrollbar.appendTo('#gallery');
    t.scroller = t.scrollbar.find('.ui-scroller');
    t.scroller.draggable({
      axis: 'x',
      cursor: 'ew-resize',
      containment: 'parent',
      drag: function(event, ui){
	t.setScrollerPosition(ui.position.left);
      },
      start: function(event, ui){
	t.setIsInDrag(true);
      },
      stop: function(event, ui){
	t.setIsInDrag(false);
      }
    });
    t.handleScrollbarResize();
  },

  initializeReflections: function(){
    var rimages = $('#gallery-photos img');
    for (i=0;i<rimages.length;i++) {
      Reflection.add(rimages[i], { height: 0.25, opacity : null});
    }
  },

  updateViewportWidth:function(width){
    var t = this, contentWidth, i = 0, width = t.context.offsetWidth;
    if (width == t.viewportWidth)
      return;
    t.viewportWidth = width;
    t.separatorsPositions = [];
    t.sections = [];

    //contentWidth = t.photosEl.offsetWidth;
    t.photosEl.style.width = '99999px';

    function updSepWidth(pos, el, width){
      //contentWidth += (width - el.offsetWidth);
      el.style.width = width + 'px';
      t.separatorsPositions.push(el.offsetLeft, el.offsetLeft + width);
      t.sections[pos] = {start: el.offsetLeft + width};
      if (window.console)
	console.debug('Updating separator:', pos, el, width);
      if (pos > 0) {
	with({s: t.sections[pos-1]}){
	  s.end = el.offsetLeft;
	  if ( (s.end - s.start) < t.viewportWidth ) {
	    s.fixed = (s.start + s.end - t.viewportWidth) / 2;
	    if (s.fixed < 0) s.fixed = 0;
	  }
	};
      }
    };

    var qInitalSep = $(t.photosEl).find('.initial-separator');
    var qSepsList = $(t.photosEl).find('.separator');
    if ( qInitalSep.length > 0 && qSepsList.length > 0 &&
	 (qSepsList[0].offsetLeft < t.viewportWidth)
       ) {
       updSepWidth(i, qInitalSep[0], (t.viewportWidth - qSepsList[0].offsetLeft) / 2 );
    } else {
      updSepWidth(i, qInitalSep[0], 0);
    }
    i ++;

    qSepsList.each(function(){
      updSepWidth(i, this, t.viewportWidth);
      i ++;
    });

    $(t.photosEl).find('.final-separator:first').each(function(){
      var lastWidth = this.offsetLeft - t.separatorsPositions[2 * i - 1];
      var newWidth = 0;

      if (lastWidth < t.viewportWidth) {
	newWidth = (t.viewportWidth - lastWidth) / 2;
      }
      updSepWidth(i, this, newWidth);
      t.sections.pop(); // Removed stacked begining on nonexistent section
      t.finalSeparatorWidth = newWidth;
    });

    //t.photosEl.style.width = contentWidth + 'px';
  },

  /* Must be after viewport width update */
  handleScrollbarResize:function(width){
    var t = this, sectionsLength = 0;
    var scrollerRange = t.scrollbar.attr('offsetWidth') -
      t.scroller.attr('offsetWidth');

    // Start calculation scrollerSections in view pixels
    t.scrollerSections = [];
    var i, length, start = 0;
    for (i = 0; i < t.sections.length; i++){
      length = t.sections[i].end - t.sections[i].start - t.viewportWidth;
      if (length < 0) length = 0;
      t.scrollerSections.push({
	start: start,
	end: start + length
      });
      start += length + t.scrollSeparatorLength;
    };

    var ratio = scrollerRange / (start - t.scrollSeparatorLength);

    // Rescale scroller sections according to scroller width, and shift
    var marg = t.scrollSeparatorLength * ratio / 2;
    for (i = 0; i < t.scrollerSections.length; i ++) {
      t.scrollerSections[i].start *= ratio;
      t.scrollerSections[i].end *= ratio;
      t.scrollerSections[i].startMargin = t.scrollerSections[i].start - marg;
      t.scrollerSections[i].endMargin = t.scrollerSections[i].end + marg;
    }

    t.scrollRatio = ratio;
    t.scrollerRange = scrollerRange;
  },

  setScrollerPosition: function(pos, inAnimation){
    var t = this;
    var scrollWindow = t.viewportWidth * t.scrollRatio;
    var viewPos, posOffset, a, b;

    for (var i = 0; i < t.scrollerSections.length; i ++){
      var s = t.scrollerSections[i];
      if (pos < s.endMargin) {
	if (pos >= s.startMargin) {
	  if ( (pos > s.start) && (pos < s.end) ) {
	    // Scrolling in regular section
	    viewPos = t.sections[i].start + (pos - s.start) / t.scrollRatio;
	    // Cancel section switch animation, if one scrolled so far
	    if (t.isInSectionSwitchAnimation) {
	      t.stopSectionSwitchAnimation();
	    }
	  } else {
	    // Scrolling in margins section

	    if (pos <= s.start) {
	      // Scrolling in margin before
	      viewPos = ( typeof(t.sections[i].fixed) != 'undefined' ) ?
		t.sections[i].fixed : t.sections[i].start;
	      posOffset = s.start - pos;
	    } else {
	      // Scrolling in margin after
	      viewPos =  ( typeof(t.sections[i].fixed) != 'undefined' ) ?
		t.sections[i].fixed : (t.sections[i].end - t.viewportWidth);
	      if (viewPos < 0) viewPos = 0;
	      posOffset = pos - s.end;
	    };

	    // Add dynamic offset correction for magnet feel, when scrolling in
	    // margin areas
	    // Using expression: y = ln(x / a + 1) * a
	    // 1 must be constant, to profide smooth join with lineral function
	    // a - inclination, should be related with scroll separator length
	    a = b =  t.scrollSeparatorLength * 0.1;
	    var orgOffset = posOffset;
	    posOffset = Math.round( Math.log( (posOffset / a) + 1) * b );
	    if (pos <= s.start) {
	      viewPos -= posOffset * t.scrollRatio;
	    } else {
	      viewPos += posOffset * t.scrollRatio;
	    }

	    if (window.console) console.log('Dyn scroll position: ' + pos);

	    // Continue running section switch animation if still in the same section,
	    // otherwise brake
	    if (t.isInSectionSwitchAnimation) {
	      if ( ( (pos <= s.start) && (t.scrollPosition > s.startMargin) ) ||
	         ( (pos >= s.end) && (t.scrollPosition < s.endMargin) )
	      ){
		t.position = viewPos;
		t.scrollPosition = pos;
		return;
	      };
	    };

	    // Animate switch between sections
	    if ( ( (pos <= s.start) && (t.scrollPosition < s.startMargin) &&
		   ( (i == 0) || (t.scrollPosition > t.scrollerSections[i - 1].startMargin)  ) ) ||
	         ( (pos >= s.end) && (t.scrollPosition > s.endMargin) &&
		   ( (i == t.scrollerSections.length - 1) || (t.scrollPosition < t.scrollerSections[i + 1].endMargin ) ) )
	       ){
	      // Cancel eventual previous animations
	      if (t.isInSectionSwitchAnimation) {
		t.stopSectionSwitchAnimation();
	      }
	      t.startSectionSwitchAnimation(viewPos);
	      t.position = viewPos;
	      t.scrollPosition = pos;
	      return;
	    };

	  };
	  break;
	};
      };
    };

    t.scrollPosition = pos;
    t.context.scrollLeft = t.position = viewPos;
  },

  setIsInDrag: function(value){
    this.isInDrag = true && value;
  },

  startSectionSwitchAnimation: function(position){
    var t = this;
    t.isInSectionSwitchAnimation = true;
    if (window.console) console.log('-- Animation started');
    $(t.context).animate({scrollLeft: position}, 200, function(){
      t.isInSectionSwitchAnimation = false;
      if (window.console) console.log('-- Animation stoped');
      // Correct eventual scroll differences after animation;
      t.context.scrollLeft = t.position;
    });
  },

  // Remeber to update position after stoping animation in the middle,
  // if not stopping with gotoEndSwitch
  stopSectionSwitchAnimation: function(gotoEnd){
    var t = this;
    $(t.context).stop(false, gotoEnd);
  }

});


$(document).ready(function(){
  var galleryController;
  function onContentChange(){
    var galleryJContext = $('#content-inner').find('#gallery-photos-viewport');
    if ( galleryJContext.length > 0 ){
      galleryController = new GalleryController( galleryJContext.get(0) );
    } else {
      galleryController = null; //Hint for garbage collector
    }
  };
  $('#content-inner').bind('change',onContentChange);
  onContentChange();
});