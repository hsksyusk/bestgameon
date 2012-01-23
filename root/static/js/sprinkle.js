/*
 Sprinkle Javascript Library
 http://www.sprinklejs.com/
 Copyright 2007 by Jon Davis <jon@jondavis.net>
 version 1.3c, last updated 9/24/2007
 
 Sprinkle is a recursive Client-Side Includes (CSI) injection function library
 so that you can "sprinkle" src=".." attributes on whatever you want and they
 will dynamically load.
 
 You're free to use this as long as you include at least the top three comment 
 lines indicating the library name and author.
*/

function dtdExtensionsCleanup() {
    // tested on MSIE 6 & 7, Safari 3, Firefox 2
    
    if((document.body.innerHTML.replace(/ /g, '').replace(/\n/g, "").substr(0, 5) == "]&gt;") 
	|| (document.body.innerHTML.substr(0, 11) == "<!--ATTLIST" || document.body.innerHTML.substr(0, 11) == "<!--ELEMENT")) {
        var subStrStartIndex = document.body.innerHTML.indexOf("&gt;", document.body.innerHTML.indexOf("]"));
        var subStrHtml = document.body.innerHTML.substring(subStrStartIndex + 4);
        document.body.innerHTML = subStrHtml;
    }  else {
        // Opera 9.23 "just works"
        
    }
}
dtdExtensionsCleanup();

function csiExec(el, recursive) {
    var attribs = el.attributes;
    var i;
    if(attribs) {
        switch(el.tagName.toLowerCase()) {
            
            
            case "span": 
            case "div": 
            case "textarea": 
            case "input": 
            // use injectProp="value" for this one
            //case .. : add more tags here as you please
            
            var j,
            d;
            for(i = 0; i < attribs.length; i ++ ) {
                if(attribs[i].name == "src") {
                    d = false;
                    for(j = 0; j < attribs.length; j ++ ) {
                        if(attribs[j].name == "csiLoadStatus" && (attribs[j].value == "loading" || attribs[j].value == "loaded")) {
                            
                            d = true;
                            break;
                            // from nested loop
                            
                        }
                    }
                    if( ! d) {
                        csiLoad(el, attribs[i].value);
                    }
                }
            }
            break;
            // from switch..case
            
        }
    }
    if(recursive) {
        for(i = 0; i < el.childNodes.length; i ++ ) {
            csiExec(el.childNodes[i], recursive);
        }
    }
}
function csiFindElementByCsiId(rootEl, csiId) {
    return findElementByAttributePair(rootEl, "csiid", csiId);
}
function findElementByAttributePair(rootEl, attribName, attribValue) {
    var attribs = el.attributes;
    var i;
    if(attribs) {
        for(i = 0; i < attribs.length; i ++ ) {
            if(attribs[i].name == attribName && attribs[i].value == attribValue) {
                return el;
            }
        }
    }
    if(el.childNodes) {
        for(i = 0; i < el.childNodes.length; i ++ ) {
            var ret = findElementByAttributePair(el.childNodes[i], attribName, attribValue);
            if(ret)
                return ret;
        }
    }
    return null;
}
function csiLoad(el, src) {
    el.attributes.setNamedItem(csiMakeAttribute("csiLoadStatus", "loading"));
    var httpRequest;
    var antiCacheMethod = csiGetAntiCacheMethod(el);
    if(antiCacheMethod == "querystring") {
        var dt = new Date();
        var dts = "" + dt.getFullYear() + dt.getMonth() + dt.getDate() + dt.getHours() + dt.getMinutes() + dt.getSeconds();
        if(src.indexOf("?") == -1)
            src += "?nocachetimestamp=" + dts;
        else src += "&nocachetimestamp=" + dts;
    }
    if(window.XMLHttpRequest) {
        // Mozilla, Safari, ...
        httpRequest = new XMLHttpRequest();
        if(httpRequest.overrideMimeType) {
            httpRequest.overrideMimeType("text/plain");
        }
    }  else
    if(window.ActiveXObject) {
        // IE
        try {
            httpRequest = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch(e) {
            try {
                httpRequest = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch(e) {}
        }
    }
    
    if( ! httpRequest) {}  else {
        httpRequest.onreadystatechange = function() {
            if(httpRequest.readyState == 4 && httpRequest.status == 200) {
                
                var newHtml = httpRequest.responseText;
                
                // This might be a full-blown HTML document; 
                // we should never pull in anything more than what's inside 
                // the <body> tag
                
                var cropBody = csiGetCropBody(el);
                if(cropBody)
                    newHtml = csiGetInnerHtmlOfTag(newHtml, "body");
                
                var injProp = csiGetInjectProp(el);
                
                switch(injProp) {
                    case "innerHTML": 
                    case "inner": 
                    case "contents": 
                    case "content": el.innerHTML = newHtml;
                    //csiReplaceHtml(el, newHtml);
                    
                    break;
                    
                    case "value": el.value = newHtml;
                    break;
                    
                    // this kind of replace really only works differently from innerHTML 
                    // when using Internet Explorer which allows you to swap out the
                    // entire tag's HTML
                    
                    case "outerHTML": 
                    case "outer": 
                    case "replace": 
                    //if (el.outerHTML) { // MSIE
                    //    el.outerHTML = newHtml;
                    //}
                    //else {
                    el = csiReplaceHtml(el, newHtml);
                    //}
                    
                    break;
                    
                }
                //Check for more src=".."
                //Only supported on innerHTML inserts, not outerHTML
                csiExec(el, true);
            }
        };
    }
    httpRequest.open("GET", src, true);
    httpRequest.send("");
    
    el.attributes.setNamedItem(csiMakeAttribute("csiLoadStatus", "loaded"));
}
function csiGetCropBody(el) {
    var defaultSetting = "on";
    var a;
    var attribs = el.attributes;
    if( ! attribs)
        return false;
    for(a = 0; a < attribs.length; a ++ ) {
        if(attribs[a].name.toLowerCase() == "cropbody") {
            return attribs[a].value.toLowerCase() == "on" || attribs[a].value.toLowerCase() == "yes" || attribs[a].value.toLowerCase() == "true" || attribs[a].value.toLowerCase() == "1";
        }
    }
    return defaultSetting == "on";
}
function csiGetAntiCacheMethod(el) {
    var defaultSetting = "disabled";
    if(el.tagName.toLowerCase() == "input")
        defaultSetting = "querystring";
    var a;
    var attribs = el.attributes;
    if( ! attribs)
        return false;
    for(a = 0; a < attribs.length; a ++ ) {
        if(attribs[a].name.toLowerCase() == "anticache") {
            return attribs[a].value.toLowerCase();
        }
    }
    return defaultSetting;
}
function csiGetInjectProp(el) {
    var defaultProp = "innerHTML";
    // Defaulting this causes problems!
    // if (el.tagName.toLowerCase() == "input") defaultProp = "value";   
    
    if(el.tagName.toLowerCase() == "input")
        defaultProp = "none";
    
    var a;
    var attribs = el.attributes;
    if( ! attribs)
        return "outerHTML";
    for(a = 0; a < attribs.length; a ++ ) {
        if(attribs[a].name.toLowerCase() == "apply") {
            return attribs[a].value;
        }
    }
    return defaultProp;
}
function csiGetInnerHtmlOfTag(str, tagName) {
    
    if(str.toLowerCase().indexOf("<" + tagName) > -1 && str.toLowerCase().indexOf("</" + tagName + ">", str.toLowerCase().indexOf("<" + tagName)) > -1) {
        
        var startTagStart = str.toLowerCase().indexOf("<" + tagName);
        var startTagEnd = str.indexOf(">", startTagStart);
        var endTagStart = str.toLowerCase().indexOf("</" + tagName, startTagEnd);
        
        var ret = str.substring(startTagEnd + 1, endTagStart - 1);
        return ret;
        
    }  else return str;
}
function csiMakeAttribute(attName, attValue) {
    var objAttribute = document.createAttribute(attName);
    objAttribute.value = attValue;
    return objAttribute;
}

function csiAutoExec() {
    csiExec(document.documentElement, true);
}
//--------------------------------------------------------------------------------------------------
function csiReplaceHtml(el, html, wrap) {
    if( ! wrap)
        wrap = false;
    var oldEl = (typeof el === "string" ? document.getElementById(el): el);
    var tagName = oldEl.nodeName;
    if(el.attributes && el.attributes["wraptag"])
        tagName = el.attributes["wraptag"].value;
    var newEl = document.createElement(tagName);
    // Preserve the element's id and class (other properties are lost)
    newEl.id = oldEl.id;
    newEl.className = oldEl.className;
    // Replace the old with the new
    newEl.innerHTML = html;
    oldEl.parentNode.replaceChild(newEl, oldEl);
    //        if (newEl.childNodes.length == 1) {
    //        	newEl = newEl.childNodes[0];
    //        	oldEl.parentNode.replaceChild(newEl, oldEl);
    //        } else {
    //        	var i;
    //        	var par = oldEl.parentNode;
    //        	var prev;
    //        		debugger;
    //        	for (i=newEl.childNodes.length-1; i>=0; i--) {
    //        		if (!prev) {
    //        			prev = par.replaceChild(newEl.childNodes[i], oldEl);
    //        		} else {
    //        			par.insertBefore(newEl.childNodes[i], prev); // doesn't work, causes weird error
    //        		}
    //        	}
    //        }
    
    /* Since we just removed the old element from the DOM, return a reference
        to the new element, which can be used to restore variable references. */
    return newEl.parentNode;
};
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
//*** The following three functions are copyright 2003 by Gavin Kistner, gavin@refinery.com
//*** They are covered under the license viewable at http://phrogz.net/JS/_ReuseLicense.txt
//***Cross browser attach event function. For 'evt' pass a string value with the leading "on" omitted
//***e.g. AttachEvent(window,'load',MyFunctionNameWithoutParenthesis,false);
function csiAttachEvent(obj, evt, fnc, useCapture) {
    if( ! useCapture)
        useCapture = false;
    if(obj.addEventListener) {
        obj.addEventListener(evt, fnc, useCapture);
        return true;
    }  else
    if(obj.attachEvent)
        return obj.attachEvent("on" + evt, fnc);
    else {
        csiNsAttachEvent(obj, evt, fnc);
        obj['on' + evt] = function() {
            csiFireEvent(obj, evt)
            };
    }
}
//The following are for browsers like NS4 or IE5Mac which don't support either
//attachEvent or addEventListener
function csiNsAttachEvent(obj, evt, fnc) {
    if( ! obj.myEvents)
        obj.myEvents = {};
    if( ! obj.myEvents[evt])
        obj.myEvents[evt] = [];
    var evts = obj.myEvents[evt];
    evts[evts.length] = fnc;
}
function csiFireEvent(obj, evt) {
    if( ! obj || !obj.myEvents || !obj.myEvents[evt])
        return;
    var evts = obj.myEvents[evt];
    for(
    var i = 0, len = evts.length; i < len; i ++ )
        evts[i]
    ();
}
//--------------------------------------------------------------------------------------------------

// Bind to window load.
csiAttachEvent(window, "load", csiAutoExec, false);