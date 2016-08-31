var path = require('path');
var vso_task_lib = require('vso-task-lib');

var echo = new vso_task_lib.ToolRunner(vso_task_lib.which('echo', true));

var msg = vso_task_lib.getInput('msg', true);
echo.arg(msg);

var cwd = vso_task_lib.getPathInput('cwd', false);

// will error and fail task if it doesn't exist
vso_task_lib.checkPath(cwd, 'cwd');
vso_task_lib.cd(cwd);

echo.exec({ failOnStdErr: false})
.then(function(code) {
    vso_task_lib.exit(code);
})
.fail(function(err) {
    console.error(err.message);
    vso_task_lib.debug('taskRunner fail');
    vso_task_lib.exit(1);
})
