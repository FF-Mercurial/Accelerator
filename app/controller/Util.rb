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
            str = str.bytes
            loop do
                begin
                    h = str.next
                    l = str.next
                rescue
                    break
                end
                if h == 0
                    chunk << l
                else
                    chunk << (l + 128)
                end
            end
            chunk
        end
    end
end
