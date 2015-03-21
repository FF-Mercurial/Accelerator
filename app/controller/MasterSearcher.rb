require './ServerSearcher'
require './Util'
require './Constants'

class MasterSearcher < ServerSearcher
    include Constants
    
    def initialize controller
        @controller = controller
        @myIpAddrs = Util.getIpAddrs
        super MULTICAST_ADDR, MULTICAST_PORT
    end

    def serverFound ipAddr
        return if @myIpAddrs.include? ipAddr
        @myIpAddrs.each do |myIpAddr|
            if myIpAddr['subnet'] == ipAddr['subnet']
                @controller.connect ipAddr['addr'], myIpAddr['addr']
                return
            end
        end
    end
end
