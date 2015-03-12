var JsonInputStream = require('./JsonInputStream');
var JsonOutputStream = require('./JsonOutputStream');

var Controller = function(input, output, inputHandler) {
    this.input = new JsonInputStream(input, inputHandler);
    this.output = new JsonOutputStream(output);
}

Controller.prototype.write = function(jsonData) {
    this.output.write(jsonData);
}

module.exports = Controller;
