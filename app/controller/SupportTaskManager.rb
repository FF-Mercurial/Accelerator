require './JsonInputStream'
require './JsonOutputStream'
require './Part'
require './SupportTask'

class SupportTaskManager
    def initialize socket
        @socket = socket
        @tasks = {}
        @input = JsonInputStream.new @socket do |jsonData|
            inputHandler jsonData
        end
    end

    def inputHanlder jsonData
        type = jsonData['type']
        case type
        when 'new'
            id = jsonData['id']
            url = jsonData['url']
            newTask id, url
        when 'delete'
            id = jsonData['id']
            deleteTask id
        when 'part'
            id = jsonData['id']
            part = jsonData['part']
            part = Part.new part[0], part[1]
            pushPart id, part
        end
    end

    def newTask id, url
        task = SupportTask.new self, id, url
        @tasks[id] = task
    end

    def deleteTask id
        @tasks[id].delete
        @tasks.delete id
    end

    def pushPart id, part
        @tasks[id].pushPart part
    end

    def nextPart id
        jsonData = {
            'type' => 'nextPart',
            'id' => id
        }
        @output.write jsonData
    end

    def sendChunk id, part, chunk
        jsonData = {
            'type' => 'chunk',
            'id' => id,
            'part' => [part.begin, part.end],
            'chunk' => chunk
        }
        @output.write jsonData
    end
end
