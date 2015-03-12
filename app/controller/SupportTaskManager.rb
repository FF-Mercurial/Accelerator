require './JsonInputStream'
require './JsonOutputStream'

class SupportTaskManager
    def initialize socket
        @socket = socket
        @input = JsonInputStream.new @socket do |jsonData|
            inputHandler jsonData
        end
    end

    def inputHanlder jsonData
        type = jsonData['type']
        case type
        when 'new'
            url = jsonData[]
        end
    end
end
