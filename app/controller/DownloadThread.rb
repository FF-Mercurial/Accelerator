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
        @thread = Thread.new do
            loop do
                @part = @task.nextPart
                break if @part == nil
                @socket = HttpRequest.get url, @part
                until @part.finished do
                    begin
                        chunk = @socket.read_nonblock BUFSIZE
                    rescue Errno::EAGAIN
                        retry
                    end
                    @task.writeChunk @part, chunk
                    @part << chunk.length
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
