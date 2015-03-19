require './Multicaster'
require './Constants'

class ClientSearcher
    include Constants

    INTERVAL = 1
    
    def initialize interval = INTERVAL
        @interval = interval
        @mc = Multicaster.new MULTICAST_ADDR, MULTICAST_PORT
        @thread = Thread.new do
            loop do
                @mc.write
                sleep @interval
            end
        end
    end

    def close
        @thread.kill
        @mc.close
    end
end
