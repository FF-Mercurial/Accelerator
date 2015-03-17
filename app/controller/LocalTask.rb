require 'json'
require 'thread'

require './DownloadThread'
require './HttpRequest'
require './ProgressMonitor'
require './Part'
require './Util'

class LocalTask
    THREADS_NUM = 2
    
    @@nextId = 0

    attr_reader :id, :url, :path

    def initialize ltm, path, url = nil
        @ltm = ltm
        @path = path
        @url = url
        # init task from file
        if (@url == nil)
            begin
                archiveFile = File.new @path + '.acc', 'r'
                task = JSON.parse archiveFile.read
                @url = task['url']
                @parts = task['parts']
                @parts.map! do |part|
                    Part.decode part
                end
                @length = task['length']
            rescue Errno::ENOENT
                raise
            end
        # init task as a new one
        else
            # partition
            @parts = []
            @length = HttpRequest.getLength @url
            partNum = getPartsNum @length
            partLength = @length / partNum
            (partNum - 1).times do |i|
                @parts << Part.new(partLength * i, partLength * (i + 1) - 1)
            end
            @parts << Part.new(partLength * (partNum - 1), @length - 1)
        end
        @partsLock = Mutex.new
        progress = @length
        @parts.each do |part|
            progress -= part.count
        end
        @pm = ProgressMonitor.new @length, progress
        @pmLock = Mutex.new
        @accelPm = ProgressMonitor.new
        @filename = @path.match(/[^\/]+$/)[0]
        @id = @@nextId
        @@nextId += 1
        @fileLock = Mutex.new
        @state = 'suspended'
        start
    end

    def suspend
        return if @state != 'running'
        @threads.each do |thread|
            part = thread.kill
            pushParts part if part != nil
        end
        @threads.clear
        @state = 'suspended'
        @fileLock.synchronize do
            @file.close
        end
    end

    def pushParts parts
        @partsLock.synchronize do
            if parts.class == Array
                @parts += parts
            else
                @parts << parts
            end
        end
    end

    def start
        return if @state != 'suspended'
        if File.exists? @path
            @file = File.new @path, 'rb+'
        else
            @file = File.new @path, 'wb'
        end
        @threads = Array.new THREADS_NUM do
            DownloadThread.new self, @url
        end
        @state = 'running'
        @url
    end

    def delete
        @threads.each do |thread|
            thread.kill
        end
        @threads.clear
        @file.close
        File.delete @path
        File.delete @path + '.acc'
    end

    def save
        parts = @parts.map do |part|
            part.encode
        end
        archiveData = {
            'url' => @url,
            'parts' => parts,
            'length' => @length
        }
        archiveFile = File.new path + '.acc', 'w'
        archiveFile.write JSON.dump archiveData
        archiveFile.close
    end

    def finish
        @file.close
        archiveFile = @path + '.acc'
        File.delete archiveFile if File.exists? archiveFile
        @ltm.finishTask @id
    end

    def nextPart
        @partsLock.synchronize do @parts.pop end
    end

    def writeChunk pos, chunk, accel = false
        Util.log 'writing file'
        @fileLock.synchronize do
            Util.log 'writing file~!' + "#{pos}"
            @file.seek pos
            Util.log 'writing file~!!'
            @file.write chunk
            Util.log 'writing file~!!!'
        end
        Util.log 'written file'
        @pmLock.synchronize do
            @accelPm << chunk.length if accel
            if @pm << chunk.length
                finish
            end
        end
    end

    def getPartsNum length
        (1000 * Math.atan(length * Math.tan(1.to_f / 200) / 10 / 1024 / 1024)).to_i + 5
    end

    def info
        @pmLock.lock
            state = @pm.state
            accelState = @accelPm.state
        @pmLock.unlock
        {
            'id' => @id,
            'url' => @url,
            'filename' => @filename,
            'length' => @length,
            'fractionalProgress' => state['fractionalProgress'],
            'speed' => state['speed'],
            'accelSpeed' => accelState['speed'],
            'remainingTime' => state['remainingTime']
        }
    end
end
