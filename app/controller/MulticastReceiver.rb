require 'socket'
require 'ipaddr'

class MulticastReceiver
    BIND_ADDR = '0.0.0.0'
    MAX_LENGTH = 1024
    
    def initialize addr, port, maxLength = MAX_LENGTH
        @socket = UDPSocket.new
        @addr = addr
        @port = port
        @maxLength = maxLength
        # membership = IPAddr.new(@addr).hton + IPAddr.new(BIND_ADDR).hton
        # @socket.setsockopt :IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership
        # @socket.setsockopt :SOL_SOCKET, :SO_REUSEPORT, 1
        # @socket.bind BIND_ADDR, @port
        @socket.bind @addr, @port
    end

    def read
        @socket.recvfrom @maxLength
    end

    def close
        @socket.close
    end
end
