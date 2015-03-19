require './ServerSearcher'
require './Util'

class MasterSearcher < ServerSearcher
    def initialize controller
        @controller = controller
        @myIpAddrs = Util.getIpAddrs
        super()
    end

    def serverFound ipAddr
        Util.log ipAddr
        @controller.connect ipAddr
        # @controller.connect ipAddr if not @myIpAddrs.include? ipAddr
    end
end
