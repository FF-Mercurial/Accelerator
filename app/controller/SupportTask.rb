require './DownloadThread'

class SupportTask
    THREADS_NUM = 5
    
    def initialize stm, id, url
        @stm = stm
        @id = id
        @url = url
        @threads = Array.new  THREADS_NUM do
            DownloadThread.new self, url
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

    def writeChunk part, chunk
        @stm.writeChunk id, part, chunk
    end
end
