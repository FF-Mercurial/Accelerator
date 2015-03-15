require 'socket'

require './Util'
require './Constants'

class SupporterListener
    include Constants
    
    def initialize sm
        @sm = sm
        addrs = Util.getIpAddrs
        addrs.each do |addr|
            Thread.new do
                server = TCPServer.new addr, PORT
                loop do
                    socket = server.accept
                    @sm.newSupporter socket
                end
            end
        end
    end
end
