require 'thread'

require './HttpRequest.rb'

class LocalThread
    BUFSIZE = 1024
    
    def initialize task, url, path
        @file = File.new path, 'r+'
        @socket = nil
        @partLock = Mutex.new
        @thread = Thread.new do
            loop do
                @partLock.synchronize do @part = task.nextPart end
                @file.seek @part.begin
                break if @part == nil
                @socket = HttpRequest.get url, @part
                until @part.finished do
                    begin
                        chunk = @socket.read_nonblock BUFSIZE
                    rescue Errno::EAGAIN
                        retry
                    end
                    @file.write chunk
                    task << chunk.length
                    @partLock.synchronize do @part << chunk.length end
                end
                @socket.close
            end
            @file.close
        end
    end

    def kill
        @thread.kill
        @socket.close if @socket != nil and not @socket.closed?
        @file.close if not @file.closed?
        @part
    end
end
