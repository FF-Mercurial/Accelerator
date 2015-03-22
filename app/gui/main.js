var cp = require('child_process');
var gui = require('nw.gui');
var fs = require('fs');
var path = require('path');
var jade = require('jade');

var Controller = require('./Controller');
var util = require('./util')

var controller;

function refresh(info) {
    var html = '';
    $('#supporters-num').html('Supporters Num: ' + info.supportersNum);
    $('#supporter-state').html('Supporter Mode: ' + (info.supporterState ? 'on' : 'off'));
    var tasks = info.tasks;
    tasks = tasks.map(function(task) {
        return {
            id: task.id,
            filename: task.filename,
            progress: (task.fractionalProgress * 100).toFixed(1) + '%',
            speed: util.formatBytes(task.speed) + '/s(+' + util.formatBytes(task.accelSpeed) + '/s)',
            remainingTime: util.formatSeconds(task.remainingTime)
        }
    });
    var html = jade.renderFile('app/gui/tasks.jade', {
        tasks: tasks
    });
    $('#tasks').html(html);
}

function cmdHandler(fullCmd) {
    var args = fullCmd.split(/\s+/);
    var cmd = args[0];
    if (cmd == 'new') {
        var url = args[1];
        if (typeof url != 'undefined') {
            $('#file-dialog').data('url', url);
            $('#file-dialog').click();
        }
    } else if (cmd == 'start' || cmd == 'suspend' || cmd == 'delete') {
        id = args[1];
        op = cmd;
        if (typeof id != 'undefined') {
            controller.manageTask(op, id);
        }
    } else if (cmd == 'close') {
        controller.closeSupporter();
    } else if (cmd == 'open') {
        controller.openSupporter();
    } else if (cmd == 'connect') {
        var ipAddr = args[1];
        var myIpAddr = args[2];
        controller.connect(ipAddr);
    }
}

function initGUI() {
    $('#file-dialog').change(function() {
        var url = $('#file-dialog').data('url');
        var path = $(this).val();
        controller.newTask(url, path);
    });
    $('#cmd-line').enter(function() {
        var cmd = $('#cmd-line').val();
        cmdHandler(cmd);
        $('#cmd-line').val('');
    });
    $('#cmd-line').toUnixStyle();
    $('#cmd-line').focus();
}

function inputHandler(type, data) {
    if (type == 'info') {
        refresh(data.info);
    } else if (type == 'exit') {
        process.exit();
    } else if (type == 'log') {
        // console.log(data.msg);
        process.stdout.write(data.msg);
    }
}

function initController() {
    var cwd = process.cwd();
    var controllerPath = path.join(cwd, 'app', 'controller');
    var rubyPath = path.join(cwd, 'Ruby', 'bin', 'ruby');
    var controllerEnd = cp.spawn(rubyPath, [path.join(controllerPath, 'main.rb')], {
        cwd: controllerPath
    });
    // capture window-close and kill the process
    var win = gui.Window.get();
    win.on('close', function() {
        // kill the controller process
        controller.exit();
    });
    // redirect stderr of the controller end to stdout of the main process
    controllerEnd.stderr.on('data', function(chunk) {
        // console.log(chunk.toString());
        process.stdout.write(chunk.toString());
    });
    process.stderr.on('data', function(chunk) {
        // console.log(chunk.toString());
        process.stdout.write(chunk.toString());
    });
    controller = new Controller(controllerEnd.stdout, controllerEnd.stdin, inputHandler);
    // refresh loop
    setInterval(function() {
        controller.fetchInfo();
    }, 100);
}

$(document).ready(function() {
    try {
        // fs.unlinkSync('tasks.dat');
    } catch (e) {
    }
    
    initGUI();
    initController();

    // test
    // var url = 'http://m1.ppy.sh/release/osu!install.exe';
    var url = 'http://dlsw.baidu.com/sw-search-sp/soft/4f/20605/BaiduType_Setup3.3.2.16.1827398843.exe';
    var path = '/mnt/shared/tmp.exe';
    // controller.newTask(url, path);
});
