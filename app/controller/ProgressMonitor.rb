require 'thread'

class ProgressMonitor
    INTERVAL = 3
    MAX_REMAINING_TIME = 100 * 3600
    
    def initialize maxProgress = 0, progress = 0, interval = INTERVAL
        @maxProgress = maxProgress
        @progress = progress
        @interval = interval
        @lock = Mutex.new
        @buf = []
    end

    def << progress, sync = true
        @lock.lock if sync
            @progress += progress
            if @buf.length > 1
                if @buf[-1]['timestamp'] - @buf[0]['timestamp'] > @interval
                    @buf.shift
                end
            end
            @buf << {
                'progress' => @progress,
                'timestamp' => Time.now.to_f
            }
            res = @progress == @maxProgress
        @lock.unlock if sync
        res
    end

    def state
        @lock.synchronize do
            self.<< 0, false
            {
                'fractionalProgress' => fractionalProgress,
                'speed' => speed,
                'remainingTime' => remainingTime
            }
        end
    end

private
    def fractionalProgress
        @progress.to_f / @maxProgress
    end

    def speed
        return 0 if @buf.length < 2
        deltaProgress = @buf[-1]['progress'] - @buf[0]['progress']
        deltaTime = @buf[-1]['timestamp'] - @buf[0]['timestamp']
        deltaProgress / deltaTime
    end

    def remainingTime
        if speed == 0
            return MAX_REMAINING_TIME
        end
        (@maxProgress - @progress) / speed
    end
end
