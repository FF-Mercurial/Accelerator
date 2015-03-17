cp = require('child_process');

var controllerPath = '/home/ff_mercurial/ff/projects/Accelerator/app/controller';
var controllerEnd = cp.spawn('ruby', [controllerPath + '/main.rb'], {
    cwd: controllerPath
});
