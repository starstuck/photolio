GalleryController = function(context){

  /* Algorith configuration constants */
  var scrollSeparatorLength = 100;
  var animationSpeed = 100;

  var isInDrag = false;
  var isInSectionSwitchAnimation = false;

  var photosEl;
  var scrollbar;
  var scroller;
  var viewportWidth;
  var separatorsPositions;
  var sections;
  var scrollPosition;
  var position;
  var scrollerSections;
  var scrollRatio;
  var scrollerRange;
  var finalSeparatorWidth;


  function initializeScroller(){
    scrollbar = $('<div class="ui-scrollbar"><div class="ui-scroller"><div class="ui-scroller-inner"></div></div><div class="ui-scrollbar-extra"></div></div>');
    scrollbar.appendTo('#gallery');
    scroller = scrollbar.find('.ui-scroller');
    scroller.draggable({
      axis: 'x',
      cursor: 'ew-resize',
      containment: 'parent',
      drag: function(event, ui){
	setScrollerPosition(ui.position.left);
      },
      start: function(event, ui){
	setIsInDrag(true);
      },
      stop: function(event, ui){
	setIsInDrag(false);
      }
    });
    handleScrollbarResize();
  }

  function initializeReflections(){
    if (window.Reflection){
      var rimages = $('#gallery-photos img');
      for (i=0;i<rimages.length;i++) {
	window.Reflection.add(rimages[i], { height: 0.25, opacity : null});
      }
      /* window.addReflections(); */
    }
  }

  function updateViewportWidth(width){
    var contentWidth, i = 0, width = context.offsetWidth;
    if (width == viewportWidth)
      return;
    viewportWidth = width;
    separatorsPositions = [];
    sections = [];

    //contentWidth = photosEl.offsetWidth;
    photosEl.style.width = '99999px';

    function updSepWidth(pos, el, width){
      //contentWidth += (width - el.offsetWidth);
      el.style.width = width + 'px';
      separatorsPositions.push(el.offsetLeft, el.offsetLeft + width);
      sections[pos] = {start: el.offsetLeft + width};
      if (window.console)
	console.debug('Updating separator:', pos, el, width);
      if (pos > 0) {
	with({s: sections[pos-1]}){
	  s.end = el.offsetLeft;
	  if ( (s.end - s.start) < viewportWidth ) {
	    s.fixed = (s.start + s.end - viewportWidth) / 2;
	    if (s.fixed < 0) s.fixed = 0;
	  }
	};
      }
    };

    var qInitalSep = $(photosEl).find('.initial-separator');
    var qSepsList = $(photosEl).find('.separator');
    if ( qInitalSep.length > 0 && qSepsList.length > 0 &&
	 (qSepsList[0].offsetLeft < viewportWidth)
       ) {
       updSepWidth(i, qInitalSep[0], (viewportWidth - qSepsList[0].offsetLeft) / 2 );
    } else {
      updSepWidth(i, qInitalSep[0], 0);
    }
    i ++;

    qSepsList.each(function(){
      updSepWidth(i, this, viewportWidth);
      i ++;
    });

    $(photosEl).find('.final-separator:first').each(function(){
      var lastWidth = this.offsetLeft - separatorsPositions[2 * i - 1];
      var newWidth = 0;

      if (lastWidth < viewportWidth) {
	newWidth = (viewportWidth - lastWidth) / 2;
      }
      updSepWidth(i, this, newWidth);
      sections.pop(); // Removed stacked begining on nonexistent section
      finalSeparatorWidth = newWidth;
    });

    //photosEl.style.width = contentWidth + 'px';
  }

  /* Must be after viewport width update */
  function handleScrollbarResize(width){
    var sectionsLength = 0;
    scrollerRange = scrollbar.attr('offsetWidth') -
      scroller.attr('offsetWidth');

    // Start calculation scrollerSections in view pixels
    scrollerSections = [];
    var i, length, start = 0;
    for (i = 0; i < sections.length; i++){
      length = sections[i].end - sections[i].start - viewportWidth;
      if (length < 0) length = 0;
      scrollerSections.push({
	start: start,
	end: start + length
      });
      start += length + scrollSeparatorLength;
    };

    var ratio = scrollerRange / (start - scrollSeparatorLength);

    // Rescale scroller sections according to scroller width, and shift
    var marg = scrollSeparatorLength * ratio / 2;
    for (i = 0; i < scrollerSections.length; i ++) {
      scrollerSections[i].start *= ratio;
      scrollerSections[i].end *= ratio;
      scrollerSections[i].startMargin = scrollerSections[i].start - marg;
      scrollerSections[i].endMargin = scrollerSections[i].end + marg;
    }

    scrollRatio = ratio;
  }

  function setScrollerPosition(pos, inAnimation){
    var t = this;
    var scrollWindow = viewportWidth * scrollRatio;
    var viewPos, posOffset, a, b;

    for (var i = 0; i < scrollerSections.length; i ++){
      var s = scrollerSections[i];
      if (pos < s.endMargin) {
	if (pos >= s.startMargin) {
	  if ( (pos > s.start) && (pos < s.end) ) {
	    // Scrolling in regular section
	    viewPos = sections[i].start + (pos - s.start) / scrollRatio;
	    // Cancel section switch animation, if one scrolled so far
	    if (isInSectionSwitchAnimation) {
	      stopSectionSwitchAnimation();
	    }
	  } else {
	    // Scrolling in margins section

	    if (pos <= s.start) {
	      // Scrolling in margin before
	      viewPos = ( typeof(sections[i].fixed) != 'undefined' ) ?
		sections[i].fixed : sections[i].start;
	      posOffset = s.start - pos;
	    } else {
	      // Scrolling in margin after
	      viewPos =  ( typeof(sections[i].fixed) != 'undefined' ) ?
		sections[i].fixed : (sections[i].end - viewportWidth);
	      if (viewPos < 0) viewPos = 0;
	      posOffset = pos - s.end;
	    };

	    // Add dynamic offset correction for magnet feel, when scrolling in
	    // section margin areas
	    // Using expression: y = ln(x / a + 1) * a
	    // 1 must be constant, to provide smooth join with lineral function
	    // a - inclination, should be related with scroll separator length
	    a = b = scrollSeparatorLength * 0.1;
	    var orgOffset = posOffset;
	    posOffset = Math.round( Math.log( (posOffset / a) + 1 ) * b );
	    if (pos <= s.start) {
	      viewPos -= posOffset * scrollRatio;
	    } else {
	      viewPos += posOffset * scrollRatio;
	    }

	    if (window.console) console.log('Dyn scroll position: ' + pos);

	    // Continue running section switch animation if still in the same section,
	    // otherwise brake
	    if (isInSectionSwitchAnimation) {
	      if ( ( (pos <= s.start) && (scrollPosition > s.startMargin) ) ||
	         ( (pos >= s.end) && (scrollPosition < s.endMargin) )
	      ){
		position = viewPos;
		scrollPosition = pos;
		return;
	      };
	    };

	    // Animate switch between sections
	    if ( ( (pos <= s.start) && (scrollPosition < s.startMargin) &&
		   ( (i == 0) || (scrollPosition > scrollerSections[i - 1].startMargin)  ) ) ||
	         ( (pos >= s.end) && (scrollPosition > s.endMargin) &&
		   ( (i == scrollerSections.length - 1) || (scrollPosition < scrollerSections[i + 1].endMargin ) ) )
	       ){
	      // Cancel eventual previous animations
	      if (isInSectionSwitchAnimation) {
		stopSectionSwitchAnimation();
	      }
	      startSectionSwitchAnimation(viewPos);
	      position = viewPos;
	      scrollPosition = pos;
	      return;
	    };

	  };
	  break;
	};
      };
    };

    scrollPosition = pos;
    context.scrollLeft = position = viewPos;
  }

  function setIsInDrag(value){
    isInDrag = true && value;
  }

  function startSectionSwitchAnimation(position){
    isInSectionSwitchAnimation = true;
    if (window.console) console.log('-- Animation started');
    $(context).animate({scrollLeft: position}, 200, function(){
      isInSectionSwitchAnimation = false;
      if (window.console) console.log('-- Animation stoped');
      // Correct eventual scroll differences after animation;
      context.scrollLeft = position;
    });
  }

  // Remeber to update position after stoping animation in the middle,
  // if not stopping with gotoEndSwitch
  function stopSectionSwitchAnimation(gotoEnd){
    $(context).stop(false, gotoEnd);
  }

  function initialize(){
    photosEl = $('#gallery-photos').get(0);
    updateViewportWidth();
    initializeScroller();
    initializeReflections();
    context.style.overflow = 'hidden';
  }

  initialize();
};
