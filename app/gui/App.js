var jade = require('jade');
var gui = global.window.nwDispatcher.requireNwGui();

var Controller = require('./Controller');
var util = require('./util');

var $ = window.$;

var App = function() {
    var inputHandler = function(type, data) {
        if (type == 'info') {
            refresh(data.info);
        } else if (type == 'exit') {
            process.exit();
        } else if (type == 'log') {
            // console.log(data.msg);
            process.stdout.write(data.msg);
        }
    }
    
    var errHandler = function(chunk) {
        process.stdout.write(chunk.toString());
    }

    var refresh = function(info) {
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
    
    var cmdHandler = function(fullCmd) {
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

    var initGUI = function() {
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
    
        // capture window close and finalize
        var win = gui.Window.get();
        win.on('close', function() {
            controller.exit();
        });
    
        // refresh loop
        setInterval(function() {
            controller.fetchInfo();
        }, 100);
    }

    var controller = new Controller(inputHandler, errHandler);
    initGUI();

    // test
    // var url = 'http://m1.ppy.sh/release/osu!install.exe';
    var url = 'http://dlsw.baidu.com/sw-search-sp/soft/4f/20605/BaiduType_Setup3.3.2.16.1827398843.exe';
    var path = '/mnt/shared/tmp.exe';
    controller.newTask(url, path);
}

module.exports = App;
