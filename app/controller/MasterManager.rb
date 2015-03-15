require './Master'

class MasterManager
    def initialize stm
        @stm = stm
        @masters = {}
    end

    def newMaster socket
        master = Master.new self, socket 
        id = master.id
        @masters[id] = master
    end

    def nextPart masterId, taskId
        @masters[masterId].nextPart taskId
    end

    def writeChunk masterId, taskId, part, chunk
        @masters[masterId].writeChunk taskId, part, chunk
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
end
