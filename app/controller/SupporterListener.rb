require 'socket'

require './Util'
require './Constants'

class SupporterListener
    include Constants
    
    def initialize sm
        @sm = sm
        server = TCPServer.new '0.0.0.0', MASTER_PORT
        @thread = Thread.new do
            loop do
                socket = server.accept
                @sm.newSupporter socket
            end
        end
    end

    def close
        @thread.kill
        server.close
    end
end
