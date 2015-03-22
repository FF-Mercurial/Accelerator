var jade = require('jade');
var fs = require('fs');

var res = jade.renderFile('app/gui/main.jade');
fs.writeFileSync('app/gui/main.html', res);
