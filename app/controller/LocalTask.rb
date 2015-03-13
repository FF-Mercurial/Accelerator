require 'json'
require 'thread'

require './LocalThread'
require './HttpRequest'
require './ProgressMonitor'
require './Part'

class LocalTask
    THREADS_NUM = 5

    @@nextId = 0

    attr_reader :id, :path

    def initialize ltm, path, url = nil
        @ltm = ltm
        @path = path
        @url = url
        File.new(@path, 'w').close if not File.exists? @path
        if (@url == nil)
            begin
                archiveFile = File.new @path + '.acc', 'r'
                task = JSON.parse archiveFile.read
                @url = task['url']
                @parts = task['parts']
                @parts.map! do |part|
                    Part.new part[0], part[1]
                end
                @length = task['length']
            rescue Errno::ENOENT
                raise
            end
        else
            @parts = []
            @length = HttpRequest.getLength @url
            partNum = getPartsNum @length
            partLength = @length / partNum
            (partNum - 1).times do |i|
                @parts << Part.new(partLength * i, partLength * (i + 1) - 1)
            end
            @parts << Part.new(partLength * (partNum - 1), @length - 1)
        end
        progress = @length
        @parts.each do |part|
            progress -= part.count
        end
        @partsLock = Mutex.new
        @pm = ProgressMonitor.new @length, progress
        @pmLock = Mutex.new
        @filename = @path.match(/[^\/]+$/)[0]
        @id = @@nextId
        @@nextId += 1
        start
    end

    def << progress
        if @pmLock.synchronize do @pm << progress end
            archiveFile = @path + '.acc'
            File.delete archiveFile if File.exists? archiveFile
            @ltm.finishTask @id
        end
    end

    def suspend
        @threads.each do |thread|
            part = thread.kill
            @partsLock.synchronize do @parts << part end if part != nil
        end
        @threads.clear
        @state = 'suspended'
    end

    def start
        @threads = Array.new THREADS_NUM do
            LocalThread.new self, @url, @path
        end
        @state = 'running'
    end

    def delete
        @threads.each do |thread|
            thread.kill
        end
        File.delete @path
        File.delete @path + '.acc'
    end

    def save
        suspend if @state == 'running'
        parts = @parts.map do |range|
            [range.begin, range.end]
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

    def nextPart
        @partsLock.synchronize do @parts.pop end
    end

    def getPartsNum length
        (1000 * Math.atan(length * Math.tan(1.to_f / 200) / 10 / 1024 / 1024)).to_i + 5
    end

    def info
        @pmLock.synchronize do
            {
                'id' => @id,
                'filename' => @filename,
                'length' => @length,
                'fractionalProgress' => @pm.fractionalProgress,
                'speed' => @pm.speed,
                'remainingTime' => @pm.remainingTime
            }
        end
    end
end
