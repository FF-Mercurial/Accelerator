require 'json'

require './LocalTask'
require './TaskManager'

class LocalTaskManager < TaskManager
    ARCHIVE_PATH = '../../tasks.dat'
    
    def initialize
        super
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

    def finishTask id
        @tasks.delete id
    end

    def saveTasks
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

    def tasks
        res = []
        @tasks.each_value do |task|
            res << task.info
        end
        res
    end

    def nextPart id
        @tasks[id].nextPart
    end

    def writeChunk id, part, chunk
        @tasks[id].writeChunk part, chunk
    end
end
