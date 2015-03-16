class StringOutputStream
    def initialize output
        @output = output
    end

    def write str
        @output.write str.length.to_s + ' ' + str
        @output.flush
    end
end
