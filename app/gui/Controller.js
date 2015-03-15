var JsonInputStream = require('./JsonInputStream');
var JsonOutputStream = require('./JsonOutputStream');

var Controller = function(input, output, inputHandler) {
    this.input = new JsonInputStream(input, function(jsonData) {
        var type = jsonData.type;
        var data = jsonData;
        delete data.type;
        inputHandler(type, data);
    });
    this.output = new JsonOutputStream(output);
}

Controller.prototype.write = function(type, data) {
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

module.exports = Controller;
