class ProgressMonitor
    INTERVAL = 3
    MAX_REMAINING_TIME = 100 * 3600
    
    def initialize maxProgress = 0, progress = 0, interval = INTERVAL
        @maxProgress = maxProgress
        @progress = progress
        @interval = INTERVAL
        @buf = []
    end

    def << progress
        @progress += progress
        @buf << {
            'progress' => @progress,
            'timestamp' => Time.now.to_f
        }
        if @buf.length > 2
            if @buf[-2]['timestamp'] - @buf[0]['timestamp'] > @interval
                @buf.shift
            end
        end
        @progress == @maxProgress
    end

    def fractionalProgress
        @progress.to_f / @maxProgress
    end

    def speed
        self << 0
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
