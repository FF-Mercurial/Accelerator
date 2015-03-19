require 'socket'

require './Util'
require './Constants'

class SupporterListener
    include Constants
    
    def initialize sm
        @sm = sm
        server = TCPServer.new 0, MASTER_PORT
        @thread = Thread.new do
            loop do
                begin
                    socket = server.accept
                    @sm.newSupporter socket
                rescue => e
                    Util.log e
                end
            end
        end
    end

    def close
        @thread.kill
        server.close
    end
end
