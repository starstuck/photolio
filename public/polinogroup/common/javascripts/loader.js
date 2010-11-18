(function(){
  var
    $,
    toRunOnjQueryLoad = [],

    // Slideshow onfiguration
    minSlideTime = 3000,
    minSlidesToGo = 3,

    // Only paths relative to this base will be handled by content loader
    loaderBasePath = window.location.pathname.match(/^(.*\/)[^\/]*$/)[1],

    // Loader and slideshow state
    documentLoaded = false,
    initialContentLoaded = false,
    slidesLoadStarted = false,
    skipSlidesShow = false,
    contentDisabled = true,

    // slideshow internal varibles
    lastSlideTime,
    slideLoadTimeout,
    availableSlides = [];


  function formatLogMessage(a){
    var d = new Date();
    var args = a;
    args[0] = d.getYear() + '-' + (d.getMonth() + 1) + '-' +
      d.getDate() + ' ' + d.getHours() + ':' +
      d.getMinutes() + ':' + d.getSeconds() + '.' + d.getMilliseconds() +
      ' ' + args[0];
    return args;
  }

  function log(message){
    // Coment-out line below, to clear debugging output
    //return;
    if (window.console) {
      console.info.apply(console, formatLogMessage(arguments));
    }
  }

  function logError(message){
    if (window.console) {
      console.error.apply(console, formatLogMessage(arguments));
    }
  }

  /* Will run code after making sure that jQuery is loaded */
  function runWithjQuery(func){
    if (typeof($) != 'undefined') {
      func($);
    } else {
      toRunOnjQueryLoad.push(func);
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
      runWithjQuery(doLoadScript);
    }
  }

  function loadScripts(urls){
    for(var i = 0; i < urls.length; i ++){
      loadScript(urls[i]);
    }
  }

  function bootstrap(jQueryUrl){

    // Do not load slides, when we are redirected among polinogroup sites
    if ( document.cookie.match(/(^| |;)slideShowPlayed=true(;|$)/) ) {
      skipSlidesShow = true;
      log('Slideshow skipped because of cookie');
    }

    scroll(0,0);
    document.documentElement.style.overflow = 'hidden';
    document.body.style.overflow = 'hidden';
    document.getElementById('loader').style.display = 'block';

    // Further initialization, when jQuery gets loaded
    loadScript(jQueryUrl, initialize, true);

    // Start loading typekit fonts
    loadScript('http://use.typekit.com/oii4ufp.js', function(){
      try{Typekit.load();}catch(e){};
      log('Typekit script loaded');
      /* if font are loading, keep querying html class names untill header font is actvated */
      if (document.documentElement.className.match(/(^| )wf-loading( |$)/)){
	var verifyFont = function(){
	  if ( document.documentElement.className.match(/(^| )wf-goodtimes1goodtimes2-n3-active( |$)/) ) {
	    log('Typekit fonts initialized');
	    runWithjQuery(function(){
	      $('#loader h1').show();
	    });
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

    for (var i=0; i < toRunOnjQueryLoad.length; i++){
      toRunOnjQueryLoad[i]($);
    }

    var urlMatch = window.location.hash.match(/\#(.*)$/);
    if ( urlMatch ) {
      loadContent( urlMatch[1] );
    } else {
      logError('No page content hash, nothing to load');
    }

    /* TODO: handle computation havy functions like below in moment, when no
     * animation is beeing done, because this will pause it in visible way
     */
    /* Change links on loaded content, to loader handled pages */
    $('#content-inner').bind('change',function() {
      var loc = window.location;
      $(this).find('a').each(function(){

	if (this.href.match(/^javascript:/)) return; // Ignore links starting with javascript
	var tMatch = this.href.match( /^(([a-z]+:)\/\/([^/:]+)(:([0-9]+))?)?(\/[^?#]*)(\#[^?]*)?(\?.*)?$/);
	var prot = tMatch[2];
	if (prot && prot != loc.protocol) return true;
	var host = tMatch[3];
	if (host && host != loc.hostname) return true;
	var port = tMatch[5];
	if (port && port != loc.port) return true;
	var path = tMatch[6], query = tMatch[8];
	if (path.match(/^\//)) {
	  if ( path.indexOf(loaderBasePath) === 0) {
	    var targetContent = ( path.slice(loaderBasePath.length) ).replace(/\.html$/, '');
	    this.href = '#' + targetContent + (query || '');
	    $(this).bind('click', function(){
	      // TODO: record browser history to allow going back
	      loadContent(targetContent + '.parthtml');
	    });
	  }
	} else {
	  // TODO: add handling relative paths
	  logError('Relative paths not supported in loaded content', this.href);
	}

	/* if initial content loded consider finalizing loder cover screen,
	 * but set it in timeout to give time for other content loaded handlers
	 * time, which may customize content */
	if (!initialContentLoaded){
 	  initialContentLoaded = true;
	  if (documentLoaded && (availableSlides.length <= 0 || skipSlidesShow))
	    setTimeout( finalize, 1);
	}

      });
      log('Links replaced in loaded content');
    });

    $(document).ready(function(){
      log('Dom ready');
      documentLoaded = true;
      $('#loader span').hide();
      if ( availableSlides.length > 0 && (! skipSlidesShow) ) {
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
    // Delay finalization untill initial content is loaded
    if (! initialContentLoaded) return;

    function onFinalize(){
      $('#loader').remove();
    }

    if ( $('#loader:visible').length > 0 ) {
      $('#loader').fadeOut('slow', function(){
	$('html,body').each(function(){
	  this.style.overflow = '';
	  onFinalize();
	});
      });
    } else {
      onFinalize();
    }

    log('Loader closed');
  }

  /* Content switching */
  function loadContent(url){
    url = url.replace(/\.html$/, '.parthtml');
    if ( ! url.match(/\.parthtml$/) )
      url += '.parthtml';
    log('Start loading page content');
    hideContent();
    $('#content-inner').load(url, null, function(response,status){
      log('Page content loaded');
      $('#content-inner').trigger('change');
      showContent();
    });
  }

  /* disable content switvhing untill enabled */
  function disableContent(){
    contentDisabled = true;
  }

  function enableContent(){
    contentDisabled = true;
  }

  function hideContent(callback){
  }

  function showContent(callback){
    if (callback) {
      callback();
    }
  }

  /* Slides handling */

  /* add number of slides presented in argument */
  function addSlides(slides){
    for (var i = 0; i < slides.length; i ++)
      availableSlides.push(slides[i]);

    if ( skipSlidesShow ) return;

    document.cookie = "slideShowPlayed=true";

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

    if (slideLoadTimeout)
      clearTimeout(slideLoadTimeout);

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
    if (initialContentLoaded && documentLoaded && minSlidesToGo <= 0) {
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
    // TODO : add timeout, when photo is loaded for to long, especially if it is first photo
    //if (document.getElementById('loader-slides'))
    document.getElementById('loader-slides').appendChild(slideImg);

    // Set timeout, in case image not get loaded and start loading another one
    slideLoadTimeout = setTimeout(function(){
      slideLoadTimeout = null;
      loadNextSlide();
    }, 2000);
  }

  function showSlide(slideEl){
    // TODO: make sure jQuery is loaded, or continue after its done
    lastSlideTime = new Date().getTime();
    runWithjQuery(function(){
      $(slideEl).fadeIn('slow');
    });
    loadNextSlide();
  }

  /* Slides handling end */

  window.loader = (function(methods){
    for (var result = {}, i = 0; i < methods.length; i ++){
      result[methods[i]] = eval(methods[i]);
    }
    return result;
  })(['bootstrap', 'loadScript', 'loadScripts', 'log', 'addSlides']);

})();
