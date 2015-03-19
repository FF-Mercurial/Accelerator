require './MyInputStream'
require './MyOutputStream'
require './BeatThread'
require './Util'

class MyTCPSocket
    def initialize socket, handler
        @socket = socket
        @handler = handler
        @beatThread = BeatThread.new self
        @input = MyInputStream.new socket do |type, data|
            if type == 'beat'
                @beatThread.beatReceived
            else
                @handler.inputHandler type, data
            end
        end
        @output = MyOutputStream.new socket
    end

    def ipAddr
        @socket.addr[3]
    end

    def close
        @input.stopReading
        @socket.close
    end

    def write type, data = {}
        begin
            @output.write type, data
        rescue
            raise
        end
    end

    def beat
        begin
            write 'beat'
        rescue
            raise
        end
    end

    def disconnected
        @handler.disconnected
    end
end
