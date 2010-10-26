/* --------- /set_cookies.js --------- */
 function MyClass()
 {
   this.myValue1 = 1;
   this.myValue2 = 2;
 }
 
 var mc = new MyClass();
 mc.myValue1 = mc.myValue2 * 2;
/* --------- END /set_cookies.js --------- */
/* --------- /seal.js --------- */
function fixPopupInIE() {
  var style = document.createElement('style');
  style.setAttribute("type", "text/css");
  document.body.appendChild(style);

  document.getElementById('wrapper').style.position = 'absolute';
  document.getElementById('shadow').style.position = 'absolute';
  document.getElementById('container').style.position = 'absolute';
  document.getElementById('popup-loading').style.position = 'absolute';
}
/* --------- END /seal.js --------- */
/* --------- /salog20.js --------- */
﻿window.onload = function() {
    var linkWithAlert = document.getElementById("alertLink");
    linkWithAlert.onclick = function() {
        return confirm('Are you sure?');
    };
};/* --------- END /salog20.js --------- */
