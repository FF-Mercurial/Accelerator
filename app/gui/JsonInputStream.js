var StringInputStream = require('./StringInputStream');

var JsonInputStream = function(input, inputHandler) {
    new StringInputStream(input, function(str) {
        var jsonData = eval('r=' + str);
        inputHandler(jsonData);
    });
}

module.exports = JsonInputStream;

// var input = new JsonInputStream(process.stdin, function(jsonData) {
    // console.log(JSON.stringify(jsonData));
// });
