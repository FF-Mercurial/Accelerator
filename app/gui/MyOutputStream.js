var JsonOutputStream = require('./JsonOutputStream');

var MyOutputStream = function(output) {
    this.output = new JsonOutputStream(output);
}

MyOutputStream.prototype.write = function(type, data) {
    var jsonData = {
        type: type
    };
    if (typeof data != 'undefined') {
        for (var key in data) {
            jsonData[key] = data[key];
        }
    }
    this.output.write(jsonData);
}

module.exports = MyOutputStream;
