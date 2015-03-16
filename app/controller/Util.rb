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

        def chunk2str chunk
            str = ''
            chunk.each_byte do |byte|
                if byte >= 128
                    str << 127
                    str << (byte - 128)
                else
                    str << 0
                    str << byte
                end
            end
            str
        end

        def str2chunk str
            chunk = ''
            i = 0
            arr = str.bytes.to_a
            while i < arr.length
                h = arr[i]
                l = arr[i + 1]
                chunk << l + h / 127
                i += 2
            end
            chunk
        end
    end
end
