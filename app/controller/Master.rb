require 'json'

require './MyInputStream'
require './MyOutputStream'
require './SupportTaskManager'
require './Part'
require './Util'

class Master
    @@nextId = 0
    
    attr_reader :id
    
    def initialize socket
        @socket = socket
        @thread = Thread.new do
            @input = MyInputStream.new socket do |type, data|
                inputHandler type, data
            end
        end
        @output = MyOutputStream.new socket
        @id = @@nextId
        @@nextId += 1
        @stm = SupportTaskManager.new self
    end

    def write type, data
        @output.write type, data
    end

    def nextPart id
        write 'nextPart', {
            'id' => id
        }
    end

    def writeChunk id, pos, chunk
        write 'chunk', {
            'id' => id,
            'pos' => pos,
            'chunk' => Util.chunk2str(chunk)
        }
    end

    def newTask id, url
        @stm.newTask id, url
    end

    def deleteTask id
        @stm.deleteTask id
    end

    def pushPart id, part
        @stm.pushPart id, part
    end

    def inputHandler type, data
        case type
        when 'new'
            id = data['id']
            url = data['url']
            newTask id, url
        when 'delete'
            id = data['id']
            newTask id
        when 'part'
            id = data['id']
            part = Part.decode data['part']
            pushPart id, part
        end
    end
end
