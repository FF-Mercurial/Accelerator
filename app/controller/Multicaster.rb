require 'socket'

class Multicaster
    def initialize addr, port
        @socket = UDPSocket.new
        @socket.setsockopt :IPPROTO_IP, :IP_MULTICAST_TTL, 128

        @addr = addr
        @port = port
    end

    def write msg = ''
        @socket.send msg, 0, @addr, @port
    end

    def close
        @socket.close
    end
end
