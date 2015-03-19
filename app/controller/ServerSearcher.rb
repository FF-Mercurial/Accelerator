require './MulticastReceiver'
require './Constants'

class ServerSearcher
    include Constants
    
    def initialize
        @mr = MulticastReceiver.new MULTICAST_ADDR, MULTICAST_PORT
        @thread = Thread.new do
            loop do
                msg, info = @mr.read
                # ipAddr = info[3]
                ipAddr = msg
                serverFound ipAddr
            end
        end
    end

    def close
        @thread.kill
        @mr.close
    end
end
