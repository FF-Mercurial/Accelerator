var FileDialog = function(input, cb) {
    this.input = input;
    var that = this;
    input.change(function() {
        cb(this.val());
    });
}

module.exports = FileDialog;
