require 'thread'

require './HttpRequest'
require './ProgressMonitor'
require './Util'

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
                    Util.log 'asking'
                    @part = @task.nextPart
                end
                Util.log @part
                break if @part == nil
                @socket = HttpRequest.get url, @part
                until @part.finished do
                    begin
                        chunk = @socket.read_nonblock BUFSIZE
                    rescue Errno::EAGAIN
                        retry
                    end
                    if chunk.length > 0
                        @task.writeChunk @part.begin, chunk
                        @partLock.synchronize do
                            @part << chunk.length
                        end
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
