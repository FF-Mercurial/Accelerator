require './MyInputStream'
require './MyOutputStream'

class Supporter
    def initialize sm, socket
        @sm = sm
        @socket = socket
        Thread.new do
            @input = MyInputStream.new socket do |type, data|
                inputHandler type, date
            end
        end
        @output = MyOutputStream.new socket
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
            sendPart nextPart id
        when 'chunk'
            id = data['id']
            part = data['part']
            chunk = data['chunk']
            writeChunk id, part, chunk
        end
    end
end
