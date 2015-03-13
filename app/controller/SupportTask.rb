require './SupportThread'

class SupportTask
    THREADS_NUM = 5
    
    def initialize stm, id, url
        @stm = stm
        @id = id
        @url = url
        @threads = Array.new  THREADS_NUM do
            SupportThread.new self, url
        end
    end

    def delete
        @threads.each do |thread|
            thread.kill
        end
    end

    def nextPart
        @stm.nextPart id
    end

    def sendChunk part, chunk
        @stm.sendChunk id, part, chunk
    end
end
