require './Multicaster'
require './Util'
require './Constants'

class ClientSearcher
    include Constants

    INTERVAL = 1
    
    def initialize interval = INTERVAL
        @interval = interval
        @mc = Multicaster.new MULTICAST_ADDR, MULTICAST_PORT
        @ipAddrs = Util.getIpAddrs
        @thread = Thread.new do
            loop do
                @ipAddrs.each do |ipAddr|
                    @mc.write ipAddr
                end
                sleep @interval
            end
        end
    end

    def close
        @thread.kill
        @mc.close
    end
end
