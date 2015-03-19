require './Supporter'
require './Util'

class SupporterManager
    def initialize ltm
        @ltm = ltm
        @supporters = []
    end

    def include? ipAddr
        count = @supporters.count do |supporter|
            supporter.ipAddr == ipAddr
        end
        count > 0
    end

    def newSupporter socket
        supporter = Supporter.new self, socket 
        tasks = @ltm.tasksInfo
        tasks.each do |task|
            supporter.newTask task['id'].to_i, task['url']
        end
        @supporters << supporter
    end

    def removeSupporter supporter, partsMap
        @ltm.pushAllParts partsMap
        @supporters.delete supporter
    end

    def newTask id, url
        @supporters.each do |supporter|
            supporter.newTask id, url
        end
    end

    def nextPart id
        @ltm.nextPart id
    end

    def writeChunk id, pos, chunk
        @ltm.writeChunk id, pos, chunk, true
    end

    def deleteTask id
        parts = []
        @supporters.each do |supporter|
            parts += supporter.deleteTask(id)
        end
        @ltm.pushParts id, parts
    end

    def deleteAll
        partsMap = {}
        @supporters.each do |supporter|
            partsMap0 = supporter.deleteAll
            partsMap0.each do |id, parts|
                partsMap[id] = [] if partsMap[id] == nil
                partsMap[id] += parts
            end
        end
        @ltm.pushAllParts partsMap
    end

    def supportersNum
        @supporters.length
    end
end
