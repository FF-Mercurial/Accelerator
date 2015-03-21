require 'thread'
require 'socket'
require 'ipaddr'

require './MyOutputStream'

class Util
    @@lock = Mutex.new
    @@output = MyOutputStream.new STDOUT
    
    class << self
        def getIpAddrs
            os = whatOS
            case os
            when 'unix'
                ifconfig = `ifconfig`
                regex = /inet addr:(\d+\.\d+\.\d+\.\d+).*?Mask:(\d+\.\d+\.\d+\.\d+)/
                matches = ifconfig.scan regex
            when 'windows'
                ipconfig = `ipconfig`
                regex = /IPv4.*?(\d+\.\d+\.\d+\.\d+)[.\n].*?(\d+\.\d+\.\d+\.\d+)/
                matches = ipconfig.scan regex
            end
            matches.delete_if do |match|
                match[0] == '127.0.0.1'
            end
            matches.map do |match|
                addr = match[0]
                mask = match[1]
                subnet = IPAddr.new("#{addr}/#{mask}").to_s
                {
                    'addr' => match[0],
                    'subnet' => subnet
                }
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

        def log msg
            @@lock.synchronize do
                @@output.write 'log', {
                    'msg' => msg.to_s + "\n"
                }
            end
        end

        def whatOS
            if RUBY_PLATFORM =~ /mingw/
                return 'windows'
            else
                return 'unix'
            end
        end
    end
end
