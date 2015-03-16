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
            chunk.each_byte do |byte|
                if byte >= 128
                    str << 1
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
    # length = rand(1024)
    # length.times do
        # chunk << rand(255)
    # end
    # res = Util.str2chunk Util.chunk2str chunk
    # puts res == chunk
# end
