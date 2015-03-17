require 'thread'

require './DownloadThread'
require './Util'

class SupportTask
    THREADS_NUM = 2
    
    def initialize stm, id, url
        @stm = stm
        @id = id
        @url = url
        @parts = []
        @partsLock = Mutex.new
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
        Util.log 'arrived'
        @lock.synchronize do
            @parts << part
            @cv.signal
            Util.log 'signaled'
        end
    end

    def nextPart
        @lock.synchronize do
            @stm.nextPart @id
            Util.log 'waiting'
            @cv.wait @lock
            Util.log 'got'
            part = @parts.pop
        end
    end

    def writeChunk pos, chunk
        @stm.writeChunk @id, pos, chunk
    end
end
