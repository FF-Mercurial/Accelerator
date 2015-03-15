var JsonInputStream = require('./JsonInputStream');

var MyInputStream = function(input, inputHandler) {
    this.input = new JsonInputStream(input, function(jsonData) {
        var type = jsonData.type;
        var data = jsonData;
        delete data.type;
        inputHandler(type, data);
    });
}

module.exports = MyInputStream;
