var $ = require('jquery');

<subtitle-box>

  <div id="subtitle-modal" if={showingBox}>
    <input id="subtitle" type="text" value={defaultSubtitle} />
  </div>

  var self = this;
  this.showingBox = false;
  this.defaultSubtitle = "DRINK! ";

  var events = opts.events;

  var currentTimestamp;

  events.on('createMarkerAtTimestamp',function(timestamp){
    self.showingBox = true;
    currentTimestamp = timestamp;
    self.update();
    $('#subtitle').focus();
  });

  var dismiss = function(){
    self.showingBox = false;
    self.update();
    events.trigger('resumeVideo');
  }

  $(document).on('keydown',function(e){
    if(self.showingBox){
      if(e.keyCode == 13){
        // enter pressed
        var text = $('#subtitle').val();
        events.trigger('createSubtitle',{ text : text, timestamp : currentTimestamp});
        dismiss();
        return false;
      } else if(e.keyCode == 27){
        // escape pressed
        dismiss();
        return false;
      }
    }
  });

</subtitle-box>
