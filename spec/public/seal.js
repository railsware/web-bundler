function fixPopupInIE() {
  var style = document.createElement('style');
  style.setAttribute("type", "text/css");
  document.body.appendChild(style);

  document.getElementById('wrapper').style.position = 'absolute';
  document.getElementById('shadow').style.position = 'absolute';
  document.getElementById('container').style.position = 'absolute';
  document.getElementById('popup-loading').style.position = 'absolute';
}
