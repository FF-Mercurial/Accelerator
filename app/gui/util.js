var bits2 = function(num) {
    num = num.toFixed(0);
    if (num.length < 2) {
        return '0' + num;
    }
    return num;
}

var formatBytes = function(bytes) {
    var units = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    var num = bytes;
    var index = 0;
    while (num >= 1024) {
        index++;
        num /= 1024;
    }
    return num.toFixed(1) + units[index];
}

var formatSeconds = function(seconds) {
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

var formatSeconds = function(seconds) {
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

var util = {
    formatBytes: formatBytes,
    formatSeconds: formatSeconds
}

module.exports = util;
