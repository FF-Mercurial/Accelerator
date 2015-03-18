require 'json'

require './LocalTask'
require './TaskManager'

class LocalTaskManager < TaskManager
    ARCHIVE_PATH = File.join '..', '..', 'tasks.dat'
    
    def initialize
        super()
        loadTasks
    end

    def newTask path, url = nil
        task = LocalTask.new self, path, url
        id = task.id
        @tasks[id] = task
        id
    end

    def startTask id
        @tasks[id].start
    end

    def suspendTask id
        @tasks[id].suspend
    end

    def suspendAll
        @tasks.each_key do |id|
            suspendTask id
        end
    end

    def finishTask id
        @tasks.delete id
    end

    def saveTasks
        suspendAll
        archiveData = []
        @tasks.each_value do |task|
            task.save
            archiveData << task.path
        end
        archiveFile = File.new ARCHIVE_PATH, 'w'
        archiveFile.write JSON.dump archiveData
        archiveFile.close
    end

    def loadTasks
        begin
            archiveFile = File.new ARCHIVE_PATH, 'r'
            paths = JSON.parse archiveFile.read
            paths.each do |path|
                newTask path
            end
        rescue Errno::ENOENT
        end
    end

    def tasksInfo
        res = []
        @tasks.each_value do |task|
            res << task.info
        end
        res
    end

    def nextPart id
        @tasks[id].nextPart
    end

    def writeChunk id, pos, chunk, accel = false
        @tasks[id].writeChunk pos, chunk, accel
    end

    def pushParts id, parts
        @tasks[id].pushParts parts
    end

    def pushAllParts partsMap
        partsMap.each do |id, parts|
            pushParts id, parts
        end
    end
end
