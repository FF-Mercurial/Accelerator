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
            'part' => part.toArray
        }
    end

    def nextPart id
        @sm.nextPart id
    end

    def writeChunk id, part, chunk
        @sm.writeChunk id, part, chunk
    end

    def inputHandler type, data
        case type
        when 'nextPart'
            id = data['id']
            part = nextPart id
            sendPart id, part
        when 'chunk'
            id = data['id']
            part = Part.new data['part']
            chunk = Util.str2chunk data['chunk'] 
            writeChunk id, part, chunk
        end
    end
end
