var path = require('path');
var cp = require('child_process');

var MyInputStream = require('./MyInputStream');
var MyOutputStream = require('./MyOutputStream');

var Controller = function(inputHandler, errHandler) {
    // spawn the ruby process
    var cwd = process.cwd();
    var controllerPath = path.join(cwd, 'app', 'controller');
    var rubyPath = path.join(cwd, 'Ruby', 'bin', 'ruby');
    var rubyProcess = cp.spawn(rubyPath, [path.join(controllerPath, 'main.rb')], {
        cwd: controllerPath
    });
    rubyProcess.stderr.on('data', errHandler);

    this.input = new MyInputStream(rubyProcess.stdout, inputHandler);
    this.output = new MyOutputStream(rubyProcess.stdin);

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
