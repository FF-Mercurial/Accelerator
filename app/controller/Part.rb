class Part
    def initialize s, t = nil
        if t != nil
            @s = s
            @t = t
        else
            array = s
            @s = array[0]
            @t = array[1]
        end
    end

    def toArray
        [@s, @t]
    end

    def << progress
        @s += progress
    end

    def finished
        @s == @t + 1
    end

    def count
        @t - @s + 1
    end

    def begin
        @s
    end

    def end
        @t
    end

    def to_s
        "#{@s}-#{@t}"
    end
end
