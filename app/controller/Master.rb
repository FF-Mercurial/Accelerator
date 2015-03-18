require 'json'

require './MyInputStream'
require './MyOutputStream'
require './SupportTaskManager'
require './Part'
require './Util'
require './MyTCPSocket'

class Master
    @@nextId = 0
    
    attr_reader :id
    
    def initialize mm, socket
        @mm = mm
        @mySocket = MyTCPSocket.new socket, self
        @id = @@nextId
        @@nextId += 1
        @stm = SupportTaskManager.new self
    end

    def write type, data
        @mySocket.write type, data
    end

    def disconnected
        @stm.deleteAll
        @mySocket.close
        @mm.removeMaster
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

    def deleteAll
        @stm.deleteAll
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
            deleteTask id
        when 'deleteAll'
            deleteAll
        when 'part'
            id = data['id']
            part = Part.decode data['part']
            pushPart id, part
        end
    end
end
