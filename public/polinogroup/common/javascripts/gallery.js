GalleryController = function(context){

  var
    // Configurations parameters
    separatorLength = 160, // expressed in view pixels, may be changed on photos scaling
    playbackSpeed = 0.07, // in view pixels per milisond
    playbackFPS = 30,

    // Gallery state
    isInDrag = false,
    isInSectionSwitchAnimation = false,

    // Internal jQuery elements
    jPhotos,
    jScrollbar,
    jScroller,

    // Internal variable used in scrolling
    viewportWidth,
    sections,
    scrollPosition, // scroller position from last update
    scrollSections,
    scrollRange,
    scrollRatio,

    // Internal variables used in playing scroll
    playbackTimeout,
    playbackLastFrameTime;


  function initializeScroller(){
    jScrollbar = $('<div class="ui-scrollbar">' +
		     '<div class="ui-scrollbar-extra"></div>' +
		     '<div class="ui-scroller">' +
		       '<div class="ui-scroller-inner"></div>' +
		     '</div>' +
		   '</div>');
    jScrollbar.appendTo('#gallery');
    jScroller = jScrollbar.find('.ui-scroller');
    jScroller.draggable({
      axis: 'x',
      cursor: 'move',
      containment: 'parent',
      drag: function(event, ui){
	setScrollPosition(ui.position.left);
      },
      start: function(event, ui){
	setIsInDrag(true);
	pause();
      },
      stop: function(event, ui){
	setIsInDrag(false);
      }
    });
    calculateScrollbarSections();
  }

  function initializeReflections(){
    if (window.Reflection){
      var rimages = $('#gallery-photos img');
      for (i=0;i<rimages.length;i++) {
	if ( typeof(rimages[i].complete) == 'undefined' || rimages[i].complete ) {
	  window.Reflection.add(rimages[i], { height: 0.25, opacity : null});
	} else {
	  rimages[i].onload = function(){
	    window.Reflection.add(this, { height: 0.25, opacity : null});
	  };
	}
      }
    }
  }

  function initializeControlls(){
    scrollPosition = 0;
    $('#gallery-play-button').bind('click', function(e){
      e.preventDefault();
      play();
    });
    $('#gallery-pause-button').hide().bind('click', function(e){
      e.preventDefault();
      pause();
    });
    $('#gallery-controls').show();

    // Playback is CPU hungry, so halt it when window is not in focus
    var stoppedOnWindowBlur = false;
    $(window).blur(function(){
      if (playbackTimeout) {
	stoppedOnWindowBlur = true;
	pause();
      }
    }).focus(function(){
      if (stoppedOnWindowBlur) {
	play();
	stoppedOnWindowBlur = false;
      }
    });
  }

  // needs to be recalucalated on resize, because separators may change
  function calculateContentSections(){
    var i = 0,
      width = context.offsetWidth,
      separatorsPositions = [];

    if (width == viewportWidth)
      return;

    sections = [];
    viewportWidth = width;

    // TODO clarify
    //viewportWidth = photosEl.offsetWidth;
    jPhotos.css('width', '99999px');

    // update each seprator width, according to surounding sections widths
    function updSepWidth(pos, el, width){
      //viewportWidth += (width - el.offsetWidth);
      el.style.width = width + 'px';
      separatorsPositions.push(el.offsetLeft, el.offsetLeft + width);
      sections[pos] = {start: el.offsetLeft + width};
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

    var qInitalSep = jPhotos.find('.initial-separator');
    var qSepsList = jPhotos.find('.separator');
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

    // Update last separator with
    jPhotos.find('.final-separator:first').each(function(){
      var lastWidth = this.offsetLeft - separatorsPositions[2 * i - 1];
      var newWidth = 0;

      if (lastWidth < viewportWidth) {
	newWidth = (viewportWidth - lastWidth) / 2;
      }
      updSepWidth(i, this, newWidth);
      sections.pop(); // Removed stacked begining on nonexistent section
    });

    // TODO: clarify
    //jPhotos.css('width', viewportWidth + 'px');
  }

  // Must be called after viewport width update
  function calculateScrollbarSections(width){
    var start = 0, length;

    // Start calculation scrollSections in view pixels
    scrollSections = [];
    for (var i = 0; i < sections.length; i++){
      length = sections[i].end - sections[i].start - viewportWidth;
      if (length < 0) length = 0;
      scrollSections.push({
	start: start,
	end: start + length
      });
      start += length + separatorLength;
    };

    scrollRange = jScrollbar.attr('offsetWidth') - jScroller.attr('offsetWidth');
    // 2 is to reduce effect of first photo margin
    scrollRatio = (start - separatorLength - 2) / scrollRange;

    // Rescale scroller sections according to scroller width, and shift
    var marg = (separatorLength / 2) / scrollRatio;
    for (i = 0; i < scrollSections.length; i ++) {
      scrollSections[i].start /= scrollRatio;
      scrollSections[i].end /= scrollRatio;
      scrollSections[i].startMargin = scrollSections[i].start - marg;
      scrollSections[i].endMargin = scrollSections[i].end + marg;
    }
  }

  function setScrollPosition(pos){
    var viewPos, posOffset, a;

    for (var i = 0; i < scrollSections.length; i ++){
      var s = scrollSections[i];
      if (pos < s.endMargin) {
	if (pos >= s.startMargin) {
	  if ( (pos > s.start) && (pos < s.end) ) {
	    // Scrolling in regular section
	    viewPos = sections[i].start + (pos - s.start) * scrollRatio;
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
	    a = ((separatorLength / 2) / scrollRatio ) * 0.5;
	    posOffset = Math.log( (posOffset / a) + 1 ) * a;
	    if (pos <= s.start) {
	      viewPos -= posOffset * scrollRatio;
	    } else {
	      viewPos += posOffset * scrollRatio;
	    }

	    // Continue running section switch animation if still in the same section,
	    // otherwise brake
	    if (isInSectionSwitchAnimation) {
	      if ( ( (pos <= s.start) && (scrollPosition > s.startMargin) ) ||
	         ( (pos >= s.end) && (scrollPosition < s.endMargin) )
	      ){
		scrollPosition = pos;
		return;
	      };
	    };

	    // Animate switch between sections
	    if ( ( (pos <= s.start) && (scrollPosition < s.startMargin) &&
		   ( (i == 0) || (scrollPosition > scrollSections[i - 1].startMargin)  ) ) ||
	         ( (pos >= s.end) && (scrollPosition > s.endMargin) &&
		   ( (i == scrollSections.length - 1) || (scrollPosition < scrollSections[i + 1].endMargin ) ) )
	       ){
	      // Cancel eventual previous animations
	      if (isInSectionSwitchAnimation) {
		stopSectionSwitchAnimation();
	      }
	      startSectionSwitchAnimation(Math.round(viewPos));
	      scrollPosition = pos;
	      return;
	    };

	  };
	  break;
	};
      };
    };

    scrollPosition = pos;
    if (! $.browser.opera) {
      context.scrollLeft = Math.round(viewPos);
    } else {
      // Opera does not support scroll left, replace by movind content
      jPhotos[0].style.left = '-' + viewPos + 'px';
    }
  }

  function play(){
    var
      scrollSpeed = playbackSpeed / scrollRatio,
      frameDelay = Math.round(1000.0 / playbackFPS);

    function playFrame(){
      var
	time = new Date(),
	offset = (time - playbackLastFrameTime) * scrollSpeed;

      setScrollPosition(scrollPosition + offset);
      jScroller[0].style.left = Math.round(scrollPosition) + 'px';
      playbackLastFrameTime = time;

      if (scrollPosition < scrollRange) {
	playbackTimeout = setTimeout(playFrame, frameDelay);
      } else {
	pause();
      }
    }

    if (scrollPosition < scrollRange) {
      playbackLastFrameTime = new Date();
      //$(context).trigger('playbackStart');
      $('#gallery-pause-button').show();
      $('#gallery-play-button').hide();
      playFrame();
    }
  }

  function pause(){
    if (playbackTimeout) {
      clearTimeout(playbackTimeout);
      playbackTimeout = null;
      //$(context).trigger('playbackStop');
      $('#gallery-pause-button').hide();
      $('#gallery-play-button').show();
    }
  }

  function setIsInDrag(value){
    isInDrag = true && value;
  }

  function startSectionSwitchAnimation(position){
    isInSectionSwitchAnimation = true;
    $(context).animate({scrollLeft: position}, 200, function(){
      isInSectionSwitchAnimation = false;
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
    jPhotos = $('#gallery-photos');
    calculateContentSections();
    initializeScroller();
    initializeControlls();
    initializeReflections();
    context.style.overflow = 'hidden';
  }

  initialize();
};
