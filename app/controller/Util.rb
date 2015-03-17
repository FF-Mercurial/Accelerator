require 'thread'

require 'socket'

class Util
    @@lock = Mutex.new
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
            str.force_encoding 'ASCII-8BIT'
            bytes = chunk.bytes
            bytes.each do |byte|
                if byte >= 128
                    h = 1
                    l = byte - 128
                else
                    h = 0
                    l = byte
                end
                str << h << l
            end
            str
        end

        def str2chunk str
            chunk = ''
            chunk.force_encoding 'ASCII-8BIT'
            bytes = str.bytes
            i = 0
            while i < bytes.length
                h = bytes[i]
                l = bytes[i + 1]
                chunk << l + h * 128
                i += 2
            end
            chunk
        end

        def log str
            @@lock.synchronize do
                STDERR.puts str
                STDERR.flush
            end
        end
    end
end

# loop do
    # chunk = ''
    # chunk.force_encoding 'ASCII-8BIT'
    # length = 1024
    # length.times do
        # chunk << rand(256)
    # end
    # str = Util.chunk2str chunk
    # res = Util.str2chunk str
    # puts res.length.to_f / chunk.length
    # puts res == chunk
# end
