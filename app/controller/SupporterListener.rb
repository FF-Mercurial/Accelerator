require 'socket'

class SupporterListener
    PORT = 15620
    
    def initilize
        @server = TCPSocket.new PORT
        @thread = Thread.new do
            loop do
                client = @server.accept
                yield client
            end
        end
    end
end
