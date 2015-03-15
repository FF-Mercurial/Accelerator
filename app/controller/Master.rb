require './MyInputStream'
require './MyOutputStream'
require './SupportTaskManager'

class Master
    NEXT_ID = 0
    
    attr_reader :id
    
    def initialize socket
        @socket = socket
        Thread.new do
            @input = MyInputStream.new socket do |type, data|
                inputHandler type, date
            end
        end
        @output = MyOutputStream.new socket
        @id = NEXT_ID
        NEXT_ID += 1
        @stm = SupportTaskManager self
    end

    def write type, data
        @output.write type, data
    end

    def nextPart id
        write 'nextPart', {
            'id' => id
        }
    end

    def writeChunk id, part, chunk
        write 'chunk', {
            'id' => id,
            'part' => part.toArray,
            'chunk' => chunk
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
            part = data['part']
            pushPart id, part
        end
    end
end
