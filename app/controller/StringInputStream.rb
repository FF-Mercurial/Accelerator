require './Util'

class StringInputStream
    BUFSIZE = 1024 * 1024
    
    def initialize input, sync = false
        @input = input
        @buf = ''
        @thread = Thread.new do
            loop do
                begin
                    # chunk = @input.read_nonblock BUFSIZE
                    chunk = @input.readpartial BUFSIZE
                    @buf << chunk
                rescue
                    retry
                end
                loop do
                    index = @buf.index ' '
                    if index != nil
                        length = @buf[0...index].to_i
                        break if @buf.length < index + 1 + length
                        @buf = @buf[index + 1..-1]
                        str = @buf[0...length]
                        @buf = @buf[length..-1]
                        yield str if block_given?
                    else
                        break
                    end
                end
            end
        end
        @thread.join if sync
    end

    def stopReading
        @thread.kill
    end
end

# test
# require './StringStream'
# stream = StringStream.new
# input = StringInputStream.new stream do |str|
    # puts "str: #{str}"
# end
# stream.write_nonblock '5 hello'
# stream.write_nonblock '5 hello'
