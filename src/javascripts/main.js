// We expose this globally so our tags can use riot without using require.js
var riot = global.riot = require('riot');

riot.mount('*');
