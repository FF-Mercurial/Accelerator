var MyInputStream = require('./MyInputStream');
var MyOutputStream = require('./MyOutputStream');

var Controller = function(input, output, inputHandler) {
    this.input = new MyInputStream(input, inputHandler);
    this.output = new MyOutputStream(output);
}

Controller.prototype.write = function(type, data) {
    this.output.write(type, data);
}

Controller.prototype.exit = function() {
    this.write('exit');
}

Controller.prototype.fetchInfo = function() {
    this.write('fetchInfo');
}

Controller.prototype.newTask = function(url, path) {
    this.write('new', {
        url: url,
        path: path
    });
}

Controller.prototype.manageTask = function(op, id) {
    this.write(op, {
        id: id
    });
}

Controller.prototype.closeSupporter = function() {
    this.write('closeSupporter');
}

Controller.prototype.openSupporter = function() {
    this.write('openSupporter');
}

Controller.prototype.connect = function(ipAddr) {
    this.write('connect', {
        ipAddr: ipAddr
    });
}

module.exports = Controller;
