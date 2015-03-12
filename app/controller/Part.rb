class Part
    def initialize s, t
        @s = s
        @t = t
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
end
