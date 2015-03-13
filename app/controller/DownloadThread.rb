require './HttpRequest.rb'

class DownloadThread
    BUFSIZE = 1024
    
    def initialize task, url
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
