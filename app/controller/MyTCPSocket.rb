require './MyInputStream'
require './MyOutputStream'
require './BeatThread'

class MyTCPSocket
    def initialize socket, handler
        @socket = socket
        @handler = handler
        @beatThread = BeatThread.new self
        @input = MyInputStream.new socket do |type, data|
            if type == 'beat'
                @beatThread.receivedBeat
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
        @beatThread.kill
        @input.stopReading
        @socket.close
    end

    def write type, data
        @output.write type, data
    end

    def beat
        write 'beat'
    end

    def disconnected
        @handler.disconnected
    end
end
