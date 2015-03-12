var StringOutputStream = function(output) {
    this.output = output;
}

StringOutputStream.prototype.write = function(str) {
    this.output.write(str.length.toString());
    this.output.write(' ');
    this.output.write(str);
}

module.exports = StringOutputStream;
