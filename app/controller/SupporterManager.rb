require './Supporter'
require './Util'

class SupporterManager
    def initialize ltm
        @ltm = ltm
        @supporters = []
    end

    def newSupporter socket
        supporter = Supporter.new self, socket 
        tasks = @ltm.tasksInfo
        tasks.each do |task|
            supporter.newTask task['id'].to_i, task['url']
        end
        @supporters << supporter
    end

    def removeSupporter supporter, parts
        @ltm.pushParts parts
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
        @ltm.pushParts parts
    end

    def deleteAll
        partsMap = {}
        @supporters.each do |supporter|
            partsMap0 = supporter.deleteAll
            partsMap0.each do |id, parts|
                partsMap[key] += value
            end
        end
        @ltm.pushAllParts partsMap
    end
end
