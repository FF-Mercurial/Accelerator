require 'thread'

require './HttpRequest'
require './ProgressMonitor'

class DownloadThread
    BUFSIZE = 1024

    @@nextId = 0
    
    def initialize task, url
        @id = @@nextId
        @@nextId += 1
        @socket = nil
        @task = task
        @partLock = Mutex.new
        @thread = Thread.new do
            loop do
                @partLock.synchronize do
                    @part = @task.nextPart
                end
                break if @part == nil
                @socket = HttpRequest.get url, @part
                until @part.finished do
                    begin
                        chunk = @socket.read_nonblock BUFSIZE
                    rescue Errno::EAGAIN
                        retry
                    end
                    @task.writeChunk @part, chunk
                    @partLock.synchronize do
                        @part << chunk.length
                    end
                end
                @socket.close
            end
        end
    end

    def kill
        @thread.kill
        @socket.close if @socket != nil and not @socket.closed?
        @part
    end
end
