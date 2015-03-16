require './MyInputStream'
require './MyOutputStream'
require './Util'

class Supporter
    def initialize sm, socket
        @sm = sm
        @socket = socket
        @output = MyOutputStream.new socket
        @thread = Thread.new do
            @input = MyInputStream.new socket do |type, data|
                inputHandler type, data
            end
        end
    end

    def write type, data
        @output.write type, data
    end

    def newTask id, url
        write 'new', {
            'id' => id,
            'url' => url
        }
    end

    def deleteTask id
        write 'delete', {
            'id' => id
        }
    end

    def sendPart id, part
        write 'part', {
            'id' => id,
            'part' => part == nil ? [] : part.encode
        }
    end

    def nextPart id
        @sm.nextPart id
    end

    def writeChunk id, pos, chunk
        @sm.writeChunk id, pos, chunk
    end

    def inputHandler type, data
        case type
        when 'nextPart'
            id = data['id']
            part = nextPart id
            sendPart id, part
        when 'chunk'
            id = data['id']
            pos = data['pos']
            chunk = Util.str2chunk data['chunk'] 
            writeChunk id, pos, chunk
        end
    end
end
