var memoryStore = {};

var getStorage = function(){
  if(typeof(Storage) !== "undefined") {
      return localStorage;
  } else {
      // Sorry! No Web Storage support..
      return false;
  }
}

var hasStorage = function(){
  return !!getStorage();
}

var serialize = function(val){
  var out = val;
  try {
    out = JSON.stringify(out);
  } catch(e){
    out = encodeURIComponent(out);
  }
  return out;
}
var decode = function(val){
  var out = val;
  try {
    out = JSON.parse(out);
  } catch(e) {
    out = decodeURIComponent(out);
  }
  return out;
}

var set = function(key,value){
  key = encodeURIComponent(key);
  memoryStore[key] = value;
  value = serialize(value);
  getStorage().setItem(key,value);
}

var get = function(key){
  key = encodeURIComponent(key);
  var memoryValue = memoryStore[key];
  if(!memoryValue){
    var val = getStorage().getItem(key);
    memoryStore[key] = memoryValue = decode(val);
  }
  return memoryValue;
}

module.exports = {
  hasStorage : hasStorage,
  set : set,
  get : get
}
