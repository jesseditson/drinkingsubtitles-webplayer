<video-player>

  <video id="{opts.id}" class="video-js vjs-sublime-skin vjs-big-play-centered"
    controls preload="auto" width="{opts.width}" height="{opts.height}"
    poster="{opts.preview}">
    <source each={sources} src={url} type={type}/>
    <p class="vjs-no-js">To view this video please enable JavaScript, and consider upgrading to a web browser that <a href="http://videojs.com/html5-video-support/" target="_blank">supports HTML5 video</a></p>
  </video>

  this.sources = opts.sources;

</video-player>
