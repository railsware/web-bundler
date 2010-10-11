function loadScript(scriptURL) {
    var newScript = document.createElement("script");
    newScript.src = scriptURL;
    document.body.appendChild(newScript);
}

function setCookie (name, value, expires, path, domain, secure) {
  var rateCookie = name + "=" + escape(value) +
    ((expires) ? "; expires=" + expires.toGMTString() : "") +
    ((path) ? "; path=" + path : "") +
    ((domain) ? "; domain=" + domain : "") +
    ((secure) ? "; secure" : "");
  document.cookie = rateCookie;
}
