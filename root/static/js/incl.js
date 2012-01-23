/**
 * incl.js
 * include html file wherever you want. For example,
 * the following line will be replaced by contents of
 * filename.html.
 * <include id='filename.html'></include>
 */
(function() {
	/**
	 * load contents and insert it to the location
	 * @private
	 * @method _render
	 */
	var _render = function() {
		var evSrc;
		if (this.contentWindow) {
			evSrc = this;
		} else {
			evSrc = this.event.srcElement;
		}
		var contents  = evSrc.contentWindow.document.body.innerHTML;
		var parent    = document.documentElement.parentNode;
		var srcUrl    = evSrc.src;
		var id        = srcUrl.substring(srcUrl.lastIndexOf('/')+1, srcUrl.length);
		var target    = parent.getElementById(id);
		var elm       = document.createElement('div');
		elm.id        = id.replace(/\..*$/,'');
		elm.innerHTML = contents;
		target.parentNode.insertBefore(elm, target);
		target.parentNode.removeChild(target);
		evSrc.parentNode.removeChild(evSrc);
		
		_removeListener(evSrc, "load", _render);
	}
	
	/**
	 * adding listner
	 * @private
	 * @method _addListenr
	 * @param el HTML element
	 * @param ev event name
	 * @param fn function name (event handler)
	 */
	var _addListener = function(el, ev, fn) {
		if (el.addEventListener) {
			el.addEventListener(ev, fn, false);
		} else if (el.attachEvent) { // IE
			el.attachEvent('on'+ev, fn);
		}
	}

	/**
	 * removing listener
	 * @param el HTML element
	 * @param ev event name
	 * @param fn function name (event handler)
	 */
	 var _removeListener = function(el, ev, fn) {
	 	if (el.removeEventListener) {
	 		el.removeEventListener(el, fn, false);
	 	} else if (el.detachEvent) { // IE
	 		el.detachEvent('on'+ev, fn);
	 	}
	 }
	
	/**
	 * execute after page loading
	 * @private
	 * @method _exec
	 */
	var _exec = function() {
		var incTags = document.getElementsByTagName('include');
		for (var i=0, l=incTags.length; i<l; ++i) {
			var incFile = incTags[i].id;
			var iframe = document.createElement('iframe');
			iframe.src = incFile;
			iframe.style.display = 'none';
			document.body.appendChild(iframe);
			_addListener(iframe, 'load', _render);
		}
	}
	
	_addListener(window, 'load', _exec);
})();
