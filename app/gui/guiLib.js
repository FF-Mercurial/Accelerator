// bind event 'enter'
$.prototype.enter = function(cb) {
    if (typeof arguments[0] == 'undefined') {
        $(this).data('enterHandler')();
    } else {
        $(this).keydown(function(e) {
            if (e.which == 13) {  // <CR>
                cb();
            }
        });
        $(this).data('enterHandler', cb);
    }
}

// change an input[type=text] to unix style
$.prototype.toUnixStyle = function() {
    var thisObject = $(this);
    // enter
    $(this).keydown(function(e) {
        if (e.which == 74 && e.ctrlKey) { // <C-j>
            thisObject.enter();
        }
    });
    // backspace
    $(this).keydown(function(e) {
        if (e.which == 8 ||  // <BS>
            (e.which == 72 && e.ctrlKey)) {  // C-h
            var tmp = thisObject.val();
            thisObject.val(tmp.substr(0, tmp.length - 1));
        }
    });
}
