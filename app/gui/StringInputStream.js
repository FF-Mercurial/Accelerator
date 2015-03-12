var StringInputStream = function(input, inputHandler) {
    var buf = '';
    
    input.on('data', function(chunk) {
        buf += chunk;
        while (true) {
            var index = buf.indexOf(' ');
            if (index == -1) {
                break;
            } else {
                var length = parseInt(buf.substr(0, index));
                if (buf.length < index + 1 + length) {
                    break;
                }
                buf = buf.substr(index + 1);
                var str = buf.substr(0, length);
                buf = buf.substr(length);
                inputHandler(str);
            }
        }
    });
}

module.exports = StringInputStream;

// test
// new StringInputStream(process.stdin, function(str) {
    // console.log(str);
// });
