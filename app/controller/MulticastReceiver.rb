require 'socket'
require 'ipaddr'

require './Util'

class MulticastReceiver
    MAX_LENGTH = 1024
    
    def initialize multicastAddr, multicastPort, maxLength = MAX_LENGTH
        @socket = UDPSocket.new
        @maxLength = maxLength
        @myIpAddrs = Util.getIpAddrs
        @myIpAddrs.each do |myIpAddr|
            membership = IPAddr.new(multicastAddr).hton + IPAddr.new(myIpAddr['addr']).hton
            @socket.setsockopt :IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership
        end
        # @socket.setsockopt :SOL_SOCKET, :SO_REUSEPORT, 1
        @socket.bind '0.0.0.0', multicastPort
    end

    def read
        @socket.recvfrom @maxLength
    end

    def close
        @socket.close
    end
end
