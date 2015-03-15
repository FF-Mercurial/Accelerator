require 'socket'

class Util
    class << self
        def getIpAddrs
            addrs = Socket.ip_address_list.select do |addr|
                addr.ipv4_private?
            end
            
            addrs.map do |addr|
                addr.ip_address
            end
        end
    end
end
