function fixPopupInIE() {
  var style = document.createElement('style');
  style.setAttribute("type", "text/css");
  if (typeof style.styleSheet != 'undefined') {
    style.styleSheet.cssText = '\
      #rp-wrapper {\
        left: 0;\
        top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        _top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        /*position: absolute;*/\
        width: 100%;\
        height: 100%;\
      }\
      #rp-shadow {\
        left: 0;\
        top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        _top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        /*position: absolute;*/\
        width: 100%;\
        height: 100%;\
      }\
      #rp-container {\
        top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        _top: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollTop : document.body.scrollTop));\
        /*position: absolute;*/\
      }\
      #rp-popup-loading {\
        left: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollLeft + (document.documentElement.clientHeight - this.clientHeight) / 2 : document.body.scrollLeft + (document.body.clientWidth - this.clientWidth) / 2));\
        _left: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollLeft + (document.documentElement.clientHeight - this.clientHeight) / 2 : document.body.scrollLeft + (document.body.clientWidth - this.clientWidth) / 2));\
        /*position: absolute;*/\
      }\
      #rp-review-popup {\
        left: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollLeft + (document.documentElement.clientHeight - this.clientHeight) / 2 : document.body.scrollLeft + (document.body.clientWidth - this.clientWidth) / 2));\
        _left: expression(eval((document.compatMode && document.compatMode=="CSS1Compat") ? document.documentElement.scrollLeft + (document.documentElement.clientHeight - this.clientHeight) / 2 : document.body.scrollLeft + (document.body.clientWidth - this.clientWidth) / 2));\
      }';
  }
  document.body.appendChild(style);

  document.getElementById('rp-wrapper').style.position = 'absolute';
  document.getElementById('rp-shadow').style.position = 'absolute';
  document.getElementById('rp-container').style.position = 'absolute';
  document.getElementById('rp-popup-loading').style.position = 'absolute';
}
