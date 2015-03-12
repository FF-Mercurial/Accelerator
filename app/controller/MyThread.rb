require 'thread'

class MyThread < Thread
    def initialize
        super
        @killed = false
        @lock = Mutex.new
    end

    def myKilled
        @lock.synchronize do
            return @killed
        end
    end

    def myKill
        @lock.synchronize do
            @killed = true
        end
    end
end
