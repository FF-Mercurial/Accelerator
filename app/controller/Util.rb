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
            buf = 0
            bufLength = 0
            bytes = chunk.bytes
            bytes.each do |byte|
                mask = 0
                (bufLength + 1).times do
                    mask <<= 1
                    mask += 1
                end
                tail = byte & mask
                nextByte = ((byte >> (bufLength + 1)) | (buf << (8 - bufLength - 1)))
                str << nextByte
                buf = tail
                bufLength += 1
                if bufLength == 7
                    str << buf
                    buf = 0
                    bufLength = 0
                end
            end
            str << (buf << (7 - bufLength)) if bufLength > 0
            str
        end

        def str2chunk str
            chunk = ''
            chunk.force_encoding 'ASCII-8BIT'
            bytes = str.bytes
            buf = 0
            bufLength = 0
            bytes.each do |byte|
                if bufLength > 1
                    mask = 0
                    (bufLength - 1).times do
                        mask <<= 1
                        mask += 1
                    end
                    tail = byte & mask
                    nextByte = (byte >> (bufLength - 1)) | (buf << (8 - bufLength))
                    chunk << nextByte
                    buf = tail
                    bufLength = bufLength - 1
                else
                    buf <<= 7
                    buf |= byte
                    bufLength += 7
                end
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
