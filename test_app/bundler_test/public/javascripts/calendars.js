jQuery(function($){
  $('.form .dates input').datepicker({
        
    buttonImageOnly: true,
    buttonImage: '/images/icon-calendar.png',
    
    showOn: 'both',
    speed: 0,
    
    closeText: '', prevText: '←', nextText: '→',
    changeFirstDay: false, 
    showOtherMonths: true });
/*    currentText: 'This month',   buttonText: 'Show calendar',
    dayNames: ['S', 'M', 'T', 'W', 'T', 'F', 'S'], 
    
  });*/

  // Modifies datepicker instance so cannot be attachet per input separately
  // therefore we need to have extra check for .autosubmit class
  $('.form .dates input.autosubmit').datepicker('change', {
    onSelect: function() {
      if (false == $(this).hasClass('autosubmit')) return;
      if (null == this['form']) return;

      this.form.submit();
    }
  });
});


