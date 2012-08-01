/*
 * Facebox (for jQuery)
 * version: 1.2 (05/05/2008)
 * @requires jQuery v1.2 or later
 *
 * Examples at http://famspam.com/facebox/
 *
 * Licensed under the MIT:
 *   http://www.opensource.org/licenses/mit-license.php
 *
 * Copyright 2007, 2008 Chris Wanstrath [ chris@ozmm.org ]
 *
 * Usage:
 *
 *  jQuery(document).ready(function() {
 *    jQuery('a[rel*=facebox]').facebox()
 *  })
 *
 *  <a href="#terms" rel="facebox">Terms</a>
 *    Loads the #terms div in the box
 *
 *  <a href="terms.html" rel="facebox">Terms</a>
 *    Loads the terms.html page in the box
 *
 *  <a href="terms.png" rel="facebox">Terms</a>
 *    Loads the terms.png image in the box
 *
 *
 *  You can also use it programmatically:
 *
 *    jQuery.facebox('some html')
 *
 *  The above will open a facebox with "some html" as the content.
 *
 *    jQuery.facebox(function($) {
 *      $.get('blah.html', function(data) { $.facebox(data) })
 *    })
 *
 *  The above will show a loading screen before the passed function is called,
 *  allowing for a better ajaxy experience.
 *
 *  The facebox function can also display an ajax page or image:
 *
 *    jQuery.facebox({ ajax: 'remote.html' })
 *    jQuery.facebox({ image: 'dude.jpg' })
 *
 *  Want to close the facebox?  Trigger the 'close.facebox' document event:
 *
 *    jQuery(document).trigger('close.facebox')
 *
 *  Facebox also has a bunch of other hooks:
 *
 *    loading.facebox
 *    beforeReveal.facebox
 *    reveal.facebox (aliased as 'afterReveal.facebox')
 *    init.facebox
 *
 *  Simply bind a function to any of these hooks:
 *
 *   $(document).bind('reveal.facebox', function() { ...stuff to do after the facebox and contents are revealed... })
 *
 */
(function($) {
  $.facebox = function(data, klass, id, callback_str) {
  	if (id == undefined) {
			ts = new Date()
			ts = ts.getTime()
			id = "facebox"+ts
		}
		if (callback_str == undefined) {
			callback_str = ''
		}
		$.facebox.settings.id = id
		$.facebox.settings.callback = callback_str
    $.facebox.loading()

    if (data.ajax) fillFaceboxFromAjax(data.ajax)
    else if (data.image) fillFaceboxFromImage(data.image)
    else if (data.div) fillFaceboxFromHref(data.div)
    else if ($.isFunction(data)) data.call($)
    else $.facebox.reveal(data, klass)
  }

  /*
   * Public, $.facebox methods
   */

  $.extend($.facebox, {
    settings: {
      opacity      : 0.25,
      callback		 : false,
      overlay      : true,
      loadingImage : '/assets/survey/loading.gif',
      closeImage   : '/assets/survey/closelabel.png',
      imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
	  	id				   : 'test',
	  	faceboxHtml  : '\
		  <div id="facebox" class="facebox" style="display:none;"> \
		    <div class="popup"> \
		      <div class="content"> \
		      </div> \
		      <a href="#" class="close"><img src="/assets/survey/closelabel.png" title="close" class="close_image" /></a> \
		    </div> \
		  </div>'
    },

    loading: function() {
      init()
      if ($('#'+$.facebox.settings.id+' .loading').length == 1) return true
      showOverlay()

      $('#'+$.facebox.settings.id+' .content').empty()
      $('#'+$.facebox.settings.id+' .body').children().hide().end().
        append('<div class="loading"><img src="'+$.facebox.settings.loadingImage+'"/></div>')

      $('#'+$.facebox.settings.id).css({
        top:	getPageScroll()[1] + (getPageHeight() / 10),
        left:	385.5
      }).show()

      $(document).bind('keydown.facebox', function(e) {
	  	var id = $.facebox.settings.id
        if (e.keyCode == 27) $.facebox.close(id)
        return true
      })
      $(document).trigger('loading.facebox')
    },

    reveal: function(data, klass) {
      $(document).trigger('beforeReveal.facebox')
      if (klass) $('#'+$.facebox.settings.id+' .content').addClass(klass)
      $('#'+$.facebox.settings.id+' .content').append(data)
      $('#'+$.facebox.settings.id+' .loading').remove()
      $('#'+$.facebox.settings.id+' .body').children().fadeIn('normal')
	  var zi = 100 + ($(".facebox").length * 2);
      $('#'+$.facebox.settings.id).css('z-index', zi).css('left', $(window).width() / 2 - ($('#'+$.facebox.settings.id+' .content').width() / 2))
      $(document).trigger('reveal.facebox').trigger('afterReveal.facebox')
    },

    close: function(id) {
      $(document).trigger('close.facebox', [id])
      return false
    }
  })

  /*
   * Public, $.fn methods
   */

  $.fn.facebox = function(settings) {
    init(settings)

    function clickHandler() {
      $.facebox.loading(true)

      // support for rel="facebox.inline_popup" syntax, to add a class
      // also supports deprecated "facebox[.inline_popup]" syntax
      var klass = this.rel.match(/facebox\[?\.(\w+)\]?/)
      if (klass) klass = klass[1]

      fillFaceboxFromHref(this.href, klass)
      return false
    }

    return this.click(clickHandler)
  }

  /*
   * Private methods
   */

  // called one time to setup facebox on this page
  function init(settings) {

    if ($("#"+$.facebox.settings.id+".facebox").length > 0) return true

    $(document).trigger('init.facebox')
    makeCompatible()

    var imageTypes = $.facebox.settings.imageTypes.join('|')
    $.facebox.settings.imageTypesRegexp = new RegExp('\.' + imageTypes + '$', 'i')

    if (settings) $.extend($.facebox.settings, settings)
    $('body').append($($.facebox.settings.faceboxHtml).attr("id", $.facebox.settings.id))

    var preload = [ new Image(), new Image() ]
    preload[0].src = $.facebox.settings.closeImage
    preload[1].src = $.facebox.settings.loadingImage

    $('#'+$.facebox.settings.id).find('.b:first, .bl, .br, .tl, .tr').each(function() {
      preload.push(new Image())
      preload.slice(-1).src = $(this).css('background-image').replace(/url\((.+)\)/, '$1')
    })

    $('#'+$.facebox.settings.id+' .close').click(function(e){
		e.preventDefault()
		$.facebox.close($(this).parents(".facebox").attr("id"))
	})
    $('#'+$.facebox.settings.id+' .close_image').attr('src', $.facebox.settings.closeImage)
  }

  // getPageScroll() by quirksmode.com
  function getPageScroll() {
    var xScroll, yScroll;
    if (self.pageYOffset) {
      yScroll = self.pageYOffset;
      xScroll = self.pageXOffset;
    } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
      yScroll = document.documentElement.scrollTop;
      xScroll = document.documentElement.scrollLeft;
    } else if (document.body) {// all other Explorers
      yScroll = document.body.scrollTop;
      xScroll = document.body.scrollLeft;
    }
    return new Array(xScroll,yScroll)
  }

  // Adapted from getPageSize() by quirksmode.com
  function getPageHeight() {
    var windowHeight
    if (self.innerHeight) {	// all except Explorer
      windowHeight = self.innerHeight;
    } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
      windowHeight = document.documentElement.clientHeight;
    } else if (document.body) { // other Explorers
      windowHeight = document.body.clientHeight;
    }
    return windowHeight
  }

  // Backwards compatibility
  function makeCompatible() {
    var $s = $.facebox.settings

    $s.loadingImage = $s.loading_image || $s.loadingImage
    $s.closeImage = $s.close_image || $s.closeImage
    $s.imageTypes = $s.image_types || $s.imageTypes
    $s.faceboxHtml = $s.facebox_html || $s.faceboxHtml
  }

  // Figures out what you want to display and displays it
  // formats are:
  //     div: #id
  //   image: blah.extension
  //    ajax: anything else
  function fillFaceboxFromHref(href, klass) {
    // div
    if (href.match(/#/)) {
      var url    = window.location.href.split('#')[0]
      var target = href.replace(url,'')
      $.facebox.reveal($(target).clone().show(), klass)

    // image
    } else if (href.match($.facebox.settings.imageTypesRegexp)) {
      fillFaceboxFromImage(href, klass)
    // ajax
    } else {
      fillFaceboxFromAjax(href, klass)
    }
  }

  function fillFaceboxFromImage(href, klass) {
    var image = new Image()
    image.onload = function() {
      $.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
    }
    image.src = href
  }

  function fillFaceboxFromAjax(href, klass) {
    $.get(href, function(data) { $.facebox.reveal(data, klass) })
  }

  function skipOverlay() {
    return $.facebox.settings.overlay == false || $.facebox.settings.opacity === null
  }

  function showOverlay() {
    if (skipOverlay()) return

    if ($('#'+$.facebox.settings.id+'_overlay.facebox_overlay').length == 0)
      $("body").append('<div id="'+$.facebox.settings.id+'_overlay" class="facebox_overlay facebox_hide"></div>')

	var id = $.facebox.settings.id;
	var zi = 99 + ($(".facebox").length * 2);

    $('#'+id+'_overlay.facebox_overlay').attr("rel", id).hide().addClass("facebox_overlayBG")
      .css('opacity', $.facebox.settings.opacity)
	  .css('z-index', zi)
      /*.click(function() {
	  	$(document).trigger('close.facebox', [$(this).attr("rel")])

		$(this).remove()
	  })*/
      .fadeIn(200)
    return false
  }

  function hideOverlay(id) {
    if (skipOverlay()) return

	if(id != undefined)
	{
		$('#' + id + '_overlay.facebox_overlay').fadeOut(200, function(){
			$('#' + id + '_overlay.facebox_overlay').removeClass("facebox_overlayBG")
			$('#' + id + '_overlay.facebox_overlay').addClass("facebox_hide")
			$('#' + id + '_overlay.facebox_overlay').remove()
		})
	}
	else
	{
		$('.facebox_overlay').fadeOut(200, function(){
			$('.facebox_overlay').removeClass("facebox_overlayBG")
			$('.facebox_overlay').addClass("facebox_hide")
			$('.facebox_overlay').remove()
		})
	}

    return false
  }

  function callbackFb() {
  	if($.facebox.settings.callback) {
  		eval($.facebox.settings.callback);
  		$.facebox.settings.callback = ''
  	}
  }

  /*
   * Bindings
   */

  $(document).bind('close.facebox', function(e, id) {
    $(document).unbind('keydown.facebox')
    if(id != undefined) {
			$('#'+id).fadeOut(function() {
		      $('#'+id+' .content').removeClass().addClass('content')
		      hideOverlay(id)
		      $('#'+id+' .loading').remove()
		      callbackFb()
		    })
		   $('#'+id).remove()
		}
		else{
			$('.facebox').fadeOut(function() {
		      $('.facebox .content').removeClass().addClass('content')
		      hideOverlay()
		      $('.facebox .loading').remove()
		    })
		  $('.facebox').remove()
		}
  })

})(jQuery);