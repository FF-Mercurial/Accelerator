require './StringInputStream'
require 'json'

class JsonInputStream
    def initialize input, sync = false
        @stringInputStream = StringInputStream.new input, sync do |str|
            jsonData = JSON.parse str
            yield jsonData
        end
    end

    def stopReading
        @stringInputStream.stopReading
    end
end

# test
# require './StringStream'
# require './JsonOutputStream'
# stream = StringStream.new
# JsonInputStream.new stream do |jsonData|
    # puts JSON.dump jsonData
# end
# output = JsonOutputStream.new stream
# jsonData = {
    # 'type' => 'info',
    # 'tasks' => []
# }
# output.write jsonData
# output.write jsonData
