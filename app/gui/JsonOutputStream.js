var StringOutputStream = require('./StringOutputStream');

var JsonOutputStream = function(output) {
    this.stringOutputStream = new StringOutputStream(output);
}

JsonOutputStream.prototype.write = function(jsonData) {
    var jsonStr = JSON.stringify(jsonData);
    this.stringOutputStream.write(jsonStr);
}

module.exports = JsonOutputStream;
