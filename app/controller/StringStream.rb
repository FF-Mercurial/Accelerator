class StringStream
    def initialize
        @buf = ''
    end

    def read_nonblock maxLength
        length = @buf.length > maxLength ? maxLength : @buf.length
        res = @buf[0...length]
        @buf = @buf[length..-1]
        res
    end

    def write_nonblock chunk
        @buf << chunk
    end
end

# test
# stream = StringStream.new
# stream.write_nonblock 'hello'
# stream.write_nonblock 'hello'
# puts stream.read_nonblock 6
# puts stream.read_nonblock 6
