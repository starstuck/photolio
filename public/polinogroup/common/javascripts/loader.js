(function(){
  var $;

  var minSlideTime = 3000;
  var minSlidesToGo = 3;

  var documentLoaded = false;
  var slidesLoadStarted = false;
  var lastSlideTime;
  var availableSlides = [];

  function log(message){
    // Coment-out line below for debugging output
    //return;
    if (window.console) {
      var d = new Date();
      var args = arguments;
      args[0] = d.getYear() + '-' + (d.getMonth() + 1) + '-' +
	d.getDate() + ' ' + d.getHours() + ':' +
	d.getMinutes() + ':' + d.getSeconds() + '.' + d.getMilliseconds() +
	' ' + args[0];
      console.debug.apply(console, args);
    }
  }

  function loadScript(url, callback, loadImidiately){
    var doLoadScript = function(){
      var headEl = document.getElementsByTagName("head")[0];
      var newScript = document.createElement('script');
      var onloadHandler = function(){
	log('Script loaded: ' + url);
	if (callback && typeof(callback) == 'function')
	  callback();
      };
      newScript.type = 'text/javascript';
      newScript.onload = onloadHandler;
      newScript.src = url;
      log('Start loading script: ' + url);
      headEl.appendChild(newScript);
    };

    if (loadImidiately) {
      doLoadScript();
    } else {
      setTimeout(doLoadScript, 1);
    }
  }

  function loadScripts(urls){
    for(var i = 0; i < urls.length; i ++){
      loadScript(urls[i]);
    }
  }

  function bootstrap(jQueryUrl){
    scroll(0,0);
    document.documentElement.style.overflow = 'hidden';
    document.body.style.overflow = 'hidden';
    document.getElementById('loader').style.display = 'block';
    loadScript(jQueryUrl, initialize, true);

    /* Start loading typekit fonts */
    loadScript('http://use.typekit.com/oii4ufp.js', function(){
      try{Typekit.load();}catch(e){};
      log('Typekit script loaded');
      /* if font are loading, keep querying html class names untill header font is actvated */
      if (document.documentElement.className.match(/(^| )wf-loading( |$)/)){
	var verifyFont = function(){
	  if ( document.documentElement.className.match(/(^| )wf-goodtimes1goodtimes2-n3-active( |$)/) ) {
	    log('Typekit fonts initialized');
	    $('#loader h1').show();
	  } else {
	    /*TODO: sort this out: if (! documentLoaded) */
	    setTimeout(verifyFont, 100);
	  }
	};
	verifyFont();
      }
    });
  }

  /* Initialization must be called after jQuery is loaded */
  function initialize(){
    $ = jQuery;

    $(document).bind('ready', function(){
      log('Dom ready');
    });

    $(window).bind('load',function(){
      log('Document loaded');
      documentLoaded = true;
      $('#loader span').hide();
      if (availableSlides.length > 0) {
	$('#loader a').show()
	  .bind('click', function(e){
	    e.preventDefault();
	    finalize();
	  });
      } else {
	finalize();
      }
    });

    /* TODO: handle resize in slideshow */

    log('Loader initialized');
  }

  function finalize(){
    $('#loader').fadeOut('slow', function(){
      $('html,body').each(function(){
	this.style.overflow = '';
      });
      $('#loader').remove();
    });
    log('Loader closed');
  }

  /* Slides handling */

  /* add number of slides presented in argument */
  function addSlides(slides){
    for (var i = 0; i < slides.length; i ++)
      availableSlides.push(slides[i]);

    /* Start loading first slide, as soon as available */
    if(! slidesLoadStarted) {
      loadNextSlide();
      slidesLoadStarted = true;
    }
  }

  function handleSlideLoad(){
    var slideEl = this;
    var slideDelay;
    log('Slide loaded: ' + slideEl.src);

    /* Find image size to cover whole page */
    var screenAspect = window.innerWidth / window.innerHeight;
    var imageAspect = this.offsetWidth / this.offsetHeight;
    if (screenAspect > imageAspect) {
      slideEl.style.width = '100%';
      slideEl.style.top = '-' + Math.round((slideEl.offsetHeight - innerHeight) / 2) + 'px';
    } else {
      slideEl.style.height = '100%';
      slideEl.style.left = '-' + Math.round((slideEl.offsetWidth - innerWidth) / 2) + 'px';
    }

    slideEl.style.display = 'none';
    slideEl.style.visibility = 'visible';

    if (lastSlideTime) {
      slideDelay = minSlideTime + lastSlideTime - new Date().getTime();
      if (slideDelay > 0) {
	setTimeout(function(){
	  showSlide(slideEl);
	}, slideDelay);
	return;
      }
    }
    showSlide(slideEl);
  }

  function loadNextSlide(){
    /* Stop loading cycle if slides were closed */
    if (! document.getElementById('loader-slides')) return;

    /* if already shown required number of slides, and document loaded, then finish */
    if (documentLoaded && minSlidesToGo <= 0) {
      setTimeout(function(){
	finalize();
      }, minSlideTime);
      return;
    }

    /* skip if run out of slides */
    if (availableSlides.length <= 0) return;

    /* slect random next slide */
    var nextSlideUrl = availableSlides.splice(
      Math.round(Math.random() * availableSlides.length - 0.5), 1);
    minSlidesToGo --;

    log('Start loading slide: ' + nextSlideUrl);
    var slideImg = new Image();
    slideImg.src = nextSlideUrl;
    slideImg.onload = handleSlideLoad;
    //if (document.getElementById('loader-slides'))
    document.getElementById('loader-slides').appendChild(slideImg);
  }

  function showSlide(slideEl){
    // TODO: make sure jQuery is loaded, or continue after its done
    lastSlideTime = new Date().getTime();
    $(slideEl).fadeIn('slow');
    loadNextSlide();
  }

  /* Slides handling end */

  function makeUtil(methods){
    var result = {};
    for (var i = 0; i < methods.length; i ++){
      result[methods[i]] = eval(methods[i]);
    }
    return result;
  }

  window.loader = makeUtil(['bootstrap', 'loadScript', 'loadScripts', 'log', 'addSlides']);
})();
