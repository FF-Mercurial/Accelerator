require 'json'

require './MulticastReceiver'
require './Constants'
require './Util'

class ServerSearcher
    def initialize multicastAddr, multicastPort
        @mr = MulticastReceiver.new multicastAddr, multicastPort
        @thread = Thread.new do
            loop do
                msg, info = @mr.read
                ipAddr = JSON.parse msg
                serverFound ipAddr
            end
        end
    end

    def close
        @thread.kill
        @mr.close
    end

    def serverFound ipAddr
        puts ipAddr
    end
end
