require 'thread'

class StringStream
    def initialize
        @buf = ''
        @lock = Mutex.new
    end

    def read_nonblock maxLength
        @lock.synchronize do
            length = @buf.length > maxLength ? maxLength : @buf.length
            res = @buf[0...length]
            @buf = @buf[length..-1]
            res
        end
    end

    def write_nonblock chunk
        @lock.synchronize do
            @buf << chunk
        end
    end

    def read maxLength
        read_nonblock maxLength
    end

    def write chunk
        write_nonblock chunk
    end
end

# test
# stream = StringStream.new
# stream.write_nonblock 'hello'
# stream.write_nonblock 'hello'
# puts stream.read_nonblock 6
# puts stream.read_nonblock 6
