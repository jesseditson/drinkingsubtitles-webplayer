var $ = require('jquery');
require('jquery-mousewheel')($);

<controls>

  <div id="controls">
    <div class="file-selector">
      <input id="video-path" type="text" name="video-path" value={defaultValue}/>
      <input type="button" value="load" onclick={load}/>
    </div>
    <div class="rangeslider" if={videoLoaded}>
      <input type="range" id="range" name="speed" min={minSpeed} value={playbackSpeed} max={maxSpeed} step=0.25 oninput={playbackRateChanged} />
      <label for="speed">{playbackSpeedStr}</label>
    </div>
    <div class="export">
      <input type="button" value="export subs" onclick={exportSubs}/>
    </div>
  </div>

  this.defaultValue = document.referrer;
  var minSpeed = this.minSpeed = 0.5;
  var maxSpeed = this.maxSpeed = 4;
  this.playbackSpeed = 1;
  this.videoLoaded = false;
  var self = this;

  var events = opts.events;

  var setPlaybackRate = function(val){
    val = parseFloat(val);
    events.trigger('changePlaybackRate',val);
    self.playbackSpeed = val;
    // round to 2 decimals
    var humanVal = Math.round(val * 100) / 100;
    self.playbackSpeedStr = humanVal + 'x';
    // for some reason riot updates the value, but the range slider doesn't change.
    $('#range').val(val);
    self.update();
  }

  exportSubs(e) {
    events.trigger('export');
  }

  playbackRateChanged(e){
    var val = parseFloat(e.target.value);
    setPlaybackRate(val);
  }

  load() {
    var filename = $("#video-path").val();
    events.trigger('videoFilename',filename);
  }

  events.on('videoLoaded',function(){
    self.videoLoaded = true;
    self.update();
  });

  var scrubFactor = 0.1;
  var speedFactor = 0.1;

  $(window).on('mousewheel', function(e) {
    var absY = Math.abs(e.deltaY);
    var absX = Math.abs(e.deltaX);
    if(absX > absY) {
      // scrolling horizontally
      var val = e.deltaX * scrubFactor;
      events.trigger('scrub',val);
    } else if(absY > absX) {
      // scrolling vertically
      // invert, as Y axis is top to bottom
      var amount = e.deltaY > 0 ? -0.02 : 0.02;
      // constrain to the max/min
      var val = Math.max(minSpeed,Math.min(maxSpeed,self.playbackSpeed + amount));
      setPlaybackRate(val);
    }
    return false;
  });

</controls>
