var riot = require('riot');

// include our tags
require('../tags/videoPlayer.tag');
require('../tags/controls.tag');
require('../tags/subtitleBox.tag');

var eventBus = riot.observable();

eventBus.on('createSubtitle',function(subtitle){
  // TODO: insert this subtitle
  console.log(subtitle);
});

riot.mount('*',{events : eventBus});
