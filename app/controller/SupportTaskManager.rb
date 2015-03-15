require './JsonInputStream'
require './JsonOutputStream'
require './Part'
require './SupportTask'
require './TaskManager'

class SupportTaskManager < TaskManager
    def initialize master
        @master = master
    end

    def newTask id, url
        task = SupportTask.new self, id, url
        @tasks[id] = task
    end

    def pushPart id, part
        @tasks[id].pushPart part
    end

    def nextPart id
        @master.nextPart id
    end

    def writeChunk id, part, chunk
        @master.writeChunk id, part, chunk
    end
end
