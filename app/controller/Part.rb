class Part
    def initialize s, t
        @s = s
        @t = t
    end

    def self.decode arr
        if arr.length == 0
            return nil
        else
            s = arr[0]
            t = arr[1]
            Part.new s, t
        end
    end

    def encode
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

    def clone
        Part.new @s, @t
    end

    def equals part
        @s == part.begin and @t == part.end
    end
end
