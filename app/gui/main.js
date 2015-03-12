var Controller = require('./Controller');
var cp = require('child_process');
var gui = require('nw.gui');

var url;
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
        html += formatBytes(task.speed) + '/s';
        html += '</div>';
        html += '<div class="remaining-time">';
        html += formatSeconds(task.remainingTime);
        html += '</div>';
        html += '</div>';
    }
    $('#displayer').html(html);
}

function contains(arr, elem) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] == elem) {
            return true;
        }
    }
    return false;
}

function cmdHandler(fullCmd) {
    var args = fullCmd.split(/\s+/);
    var cmd = args[0];
    if (cmd == 'new') {
        url = args[1];
        if (typeof url != 'undefined') {
            $('#file-dialog').click();
        }
    } else if (contains(['suspend', 'start', 'delete'], cmd)) {
        id = args[1];
        if (typeof id != 'undefined') {
            var jsonData = {
                type: cmd,
                id: id
            }
            controller.write(jsonData);
        }
    }
}

function initGUI() {
    $('#file-dialog').change(function() {
        var path = $(this).val();
        var jsonData = {
            type: 'new',
            url: url,
            path: path
        };
        controller.write(jsonData);
    });
    $('#cmd-line').enter(function() {
        var cmd = $('#cmd-line').val();
        cmdHandler(cmd);
        $('#cmd-line').val('');
    });
    $('#cmd-line').toUnixStyle();
    $('#cmd-line').focus();
}

function inputHandler(jsonData) {
    var type = jsonData.type;
    if (type == 'info') {
        refresh(jsonData.info);
    } else if (type == 'exit') {
        process.exit();
    }
}

function initController() {
    var controllerPath = '/app/controller';
    // var controllerPath = '/../controller';
    var controllerEnd = cp.spawn('ruby', [process.cwd() + controllerPath + '/main.rb'], {
        cwd: process.cwd() + controllerPath
    });
    // capture window-close and kill the process
    var win = gui.Window.get();
    win.on('close', function() {
        // kill the controller process
        jsonData = {
            type: 'exit'
        }
        controller.write(jsonData);
    });
    // redirect stderr of the controller end to stdout of the main process
    controllerEnd.stderr.on('data', function(chunk) {
        process.stdout.write(String(chunk));
    });
    process.stderr.on('data', function(chunk) {
        process.stdout.write(String(chunk));
    });
    controller = new Controller(controllerEnd.stdout, controllerEnd.stdin, inputHandler);
    // refresh loop
    setInterval(function() {
        var jsonData = {
            type: 'info'
        }
        controller.write(jsonData);
    }, 100);
}

$(document).ready(function() {
    initGUI();
    initController();

    var jsonData = {
        type: 'new',
        // url: 'http://m1.ppy.sh/release/osu!install.exe',
        url: 'http://dlsw.baidu.com/sw-search-sp/soft/4f/20605/BaiduType_Setup3.3.2.16.1827398843.exe',
        path: '/mnt/shared/tmp.exe'
    }
    controller.write(jsonData);
});
