require './MyInputStream'
require './MyOutputStream'
require './Util'
require './MyTCPSocket'

class Supporter
    def initialize sm, socket
        @sm = sm
        @mySocket = MyTCPSocket.new socket, self
        @partsMap = {}
    end

    def ipAddr
        @mySocket.ipAddr
    end

    def write type, data = {}
        @mySocket.write type, data
    end

    def disconnected
        @mySocket.close
        @sm.removeSupporter self, @partsMap
    end

    def newTask id, url
        @partsMap[id] = []
        write 'new', {
            'id' => id,
            'url' => url
        }
    end

    def deleteTask id
        parts = @partsMap[id]
        @partsMap.delete id
        write 'delete', {
            'id' => id
        }
        parts
    end

    def deleteAll
        write 'deleteAll'
        @partsMap
    end

    def sendPart id, part
        @partsMap[id] << part if part != nil
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
        parts = @partsMap[id]
        parts.each do |part|
            if part.begin == pos
                part << chunk.length
                if part.finished
                    parts.delete part
                end
                break
            end
        end
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
