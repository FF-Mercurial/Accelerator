require 'thread'

class StringOutputStream
    def initialize output
        @output = output
        @lock = Mutex.new
    end

    def write str
        @lock.synchronize do
            @output.write str.length.to_s + ' ' + str
            @output.flush
        end
    end
end
