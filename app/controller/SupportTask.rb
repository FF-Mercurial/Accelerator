require 'thread'

require './DownloadThread'

class SupportTask
    THREADS_NUM = 1
    
    def initialize stm, id, url
        @stm = stm
        @id = id
        @url = url
        @part = nil
        @lock = Mutex.new
        @cv = ConditionVariable.new
        @threads = Array.new THREADS_NUM do
            DownloadThread.new self, url
        end
    end

    def delete
        @threads.each do |thread|
            thread.kill
        end
    end

    def pushPart part
        @lock.synchronize do
            @part = part
            @cv.signal
        end
    end

    def nextPart
        @stm.nextPart @id
        @lock.synchronize do
            @cv.wait @lock
            @part
        end
    end

    def writeChunk part, chunk
        @stm.writeChunk @id, part, chunk
    end
end
