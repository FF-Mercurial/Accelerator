require './StringOutputStream'
require 'json'

class JsonOutputStream
    def initialize output
        @stringOutputStream = StringOutputStream.new output
    end

    def write jsonData
        @stringOutputStream.write JSON.dump jsonData
    end
end

# test
# output = JsonOutputStream.new STDOUT
# jsonData = {
    # 'type' => 'log',
    # 'msg' => 'hello'
# }
# output.write jsonData
