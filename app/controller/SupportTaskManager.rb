require './JsonInputStream'
require './JsonOutputStream'
require './Part'
require './SupportTask'
require './TaskManager'

class SupportTaskManager < TaskManager
    def initialize master
        super()
        @master = master
    end

    def newTask id, url
        task = SupportTask.new self, id, url
        @tasks[id] = task
    end

    def deleteTask id
        @tasks[id].delete
    end

    def deleteAll
        @tasks.each_key do |id|
            deleteTask id
        end
    end

    def pushPart id, part
        @tasks[id].pushPart part
    end

    def nextPart id
        @master.nextPart id
    end

    def writeChunk id, pos, chunk
        @master.writeChunk id, pos, chunk
    end
end
