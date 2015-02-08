<controls>

  <div id="controls">
    <div class="file-selector">
      <input type="file" name="videofile" onchange={fileSelected}/>
    </div>
  </div>

  fileSelected(e) {
    console.log(e);
  }

</controls>
