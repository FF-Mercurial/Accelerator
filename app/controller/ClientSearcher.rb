require 'json'

require './Multicaster'
require './Util'
require './Constants'

class ClientSearcher
    INTERVAL = 1
    
    def initialize multicastAddr, multicastPort, interval = INTERVAL
        @interval = interval
        @mc = Multicaster.new multicastAddr, multicastPort
        @ipAddrs = Util.getIpAddrs
        @thread = Thread.new do
            loop do
                @ipAddrs.each do |ipAddr|
                    @mc.write JSON.dump ipAddr
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
