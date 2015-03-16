require './Supporter'

class SupporterManager
    def initialize ltm
        @ltm = ltm
        @supporters = []
    end

    def newSupporter socket
        supporter = Supporter.new self, socket 
        @supporters << supporter
    end

    def newTask id, url
        @supporters.each do |supporter|
            supporter.newTask id, url
        end
    end

    def deleteTask id
        @supporters.each do |supporter|
            supporter.deleteTask id
        end
    end

    def nextPart id
        @ltm.nextPart id
    end

    def writeChunk id, pos, chunk
        @ltm.writeChunk id, pos, chunk, true
    end
end
