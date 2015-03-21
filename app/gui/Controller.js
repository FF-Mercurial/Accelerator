var MyInputStream = require('./MyInputStream');
var MyOutputStream = require('./MyOutputStream');

var Controller = function(input, output, inputHandler) {
    this.input = new MyInputStream(input, inputHandler);
    this.output = new MyOutputStream(output);

    this.write = function(type, data) {
        this.output.write(type, data);
    }
    
    this.exit = function() {
        this.write('exit');
    }
    
    this.fetchInfo = function() {
        this.write('fetchInfo');
    }
    
    this.newTask = function(url, path) {
        this.write('new', {
            url: url,
            path: path
        });
    }
    
    this.manageTask = function(op, id) {
        this.write(op, {
            id: id
        });
    }
    
    this.closeSupporter = function() {
        this.write('closeSupporter');
    }
    
    this.openSupporter = function() {
        this.write('openSupporter');
    }
    
    this.connect = function(ipAddr, myIpAddr) {
        this.write('connect', {
            ipAddr: ipAddr,
            myIpAddr: myIpAddr
        });
    }
}


module.exports = Controller;
