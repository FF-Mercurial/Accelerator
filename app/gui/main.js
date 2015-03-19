var Controller = require('./Controller');
var cp = require('child_process');
var gui = require('nw.gui');
var fs = require('fs');
var path = require('path');

var controller;

function formatBytes(bytes) {
    var units = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    var num = bytes;
    var index = 0;
    while (num >= 1024) {
        index++;
        num /= 1024;
    }
    return num.toFixed(1) + units[index];
}

function bits2(num) {
    num = num.toFixed(0);
    if (num.length < 2) {
        return '0' + num;
    }
    return num;
}

function formatSeconds(seconds) {
    var hours, minutes;
    hours = seconds / 3600;
    if (hours > 99) {
        return '99:59:59';
    }
    seconds %= 3600;
    minutes = seconds / 60;
    seconds %= 60;
    return bits2(hours) + ':' + bits2(minutes) + ':' + bits2(seconds);
}

function refresh(info) {
    var html = '';
    $('#supporters-num').html('Supporters Num: ' + info.supportersNum);
    $('#supporter-state').html('Supporter Mode: ' + (info.supporterState ? 'on' : 'off'));
    var tasks = info.tasks;
    for (var i = 0; i < tasks.length; i++) {
        var task = tasks[i];
        html += '<div class="task">';
        html += '<div class="id">';
        html += task.id;
        html += '</div>';
        html += '<div class="filename">';
        html += task.filename;
        html += '</div>';
        html += '<div class="fractional-progress">';
        html += (task.fractionalProgress * 100).toFixed(1) + '%';
        html += '</div>';
        html += '<div class="speed">';
        html += formatBytes(task.speed) + '/s(+' + formatBytes(task.accelSpeed) + '/s)';
        html += '</div>';
        html += '<div class="remaining-time">';
        html += formatSeconds(task.remainingTime);
        html += '</div>';
        html += '</div>';
    }
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
    } else if (cmd == 'closeSupporter') {
        controller.closeSupporter();
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
        process.stdout.write(String(chunk));
    });
    process.stderr.on('data', function(chunk) {
        // console.log(String(chunk));
        process.stdout.write(String(chunk));
    });
    controller = new Controller(controllerEnd.stdout, controllerEnd.stdin, inputHandler);
    // refresh loop
    setInterval(function() {
        controller.fetchInfo();
    }, 100);
}

$(document).ready(function() {
    try {
        fs.unlinkSync('tasks.dat');
    } catch (e) {
    }
    
    initGUI();
    initController();

    // var url = 'http://m1.ppy.sh/release/osu!install.exe';
    var url = 'http://dlsw.baidu.com/sw-search-sp/soft/4f/20605/BaiduType_Setup3.3.2.16.1827398843.exe';
    var path = 'tmp.exe';
    controller.newTask(url, path);
    // controller.connect('172.18.34.241');
});
