require './ClientSearcher'
require './Constants'

class SupporterSearcher < ClientSearcher
    include Constants
    
    def initialize
        super MULTICAST_ADDR, MULTICAST_PORT
    end
end
