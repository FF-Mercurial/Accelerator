require 'json'

require './LocalTask'

class LocalTaskManager
    ARCHIVE_PATH = '../../tasks.dat'
    
    def initialize
        @tasks = {}
        loadTasks
    end

    def newTask path, url = nil
        task = LocalTask.new self, path, url
        @tasks[task.id] = task
    end

    def suspendTask id
        @tasks[id].suspend
    end

    def startTask id
        @tasks[id].start
    end

    def deleteTask id
        @tasks[id].delete
        @tasks.delete id
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
                newTask 'path' => path
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
end
