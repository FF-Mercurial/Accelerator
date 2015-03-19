require 'thread'

require './Util'

class BeatThread < Thread
    INTERVAL = 1
    UPPER_BOUNCE = 3
    
    def initialize mySocket, interval = INTERVAL, upperBounce = UPPER_BOUNCE
        @mySocket = mySocket
        @interval = interval
        @upperBounce = upperBounce
        @lock = Mutex.new
        @count = 0
        super do
            loop do
                sleep @interval
                if @count == UPPER_BOUNCE
                    disconnected
                end
                begin
                    @mySocket.beat
                rescue
                    disconnected
                end
                @lock.synchronize do
                    @count += 1
                end
            end
        end
    end

    def disconnected
        @mySocket.disconnected
        kill
    end

    def beatReceived
        @lock.synchronize do
            @count -= 1
        end
    end
end
