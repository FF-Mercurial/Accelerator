require './MyInputStream'
require './MyOutputStream'
require './LocalTaskManager'
require './SupporterManager'
require './MasterManager'
require './SupporterListener'
require './Util'

class Controller
    include Constants
    
    def initialize
        @ltm = LocalTaskManager.new
        @stms = []
        @sm = SupporterManager.new @ltm
        @sl = SupporterListener.new @sm
        @mm = MasterManager.new
        @output = MyOutputStream.new STDOUT
        @input = MyInputStream.new STDIN do |type, data|
            inputHandler type, data
        end
    end

    def write type, data = {}
        @output.write type, data
    end

    def newTask path, url
        id = @ltm.newTask path, url
        @sm.newTask id, url
    end

    def startTask id
        url = @ltm.startTask id
        @sm.newTask id, url
    end

    def suspendTask id
        @ltm.suspendTask id
        parts = @sm.deleteTask id
        @ltm.pushParts id, parts
    end

    def deleteTask id
        @ltm.deleteTask id
        @sm.deleteTask id
    end

    def connect ipAddr
        socket = TCPSocket.new ipAddr, PORT
        @mm.newMaster socket
    end

    def sendInfo
        data = {
            'info' => {
                'tasks' => @ltm.tasksInfo
            }
        }
        write 'info', data
    end

    def finalize
        tasksInfo = @ltm.tasksInfo
        tasksInfo.each do|taskInfo|
            id = taskInfo['id']
            parts = @sm.deleteTask id
            @ltm.pushParts id, parts
        end
        @ltm.saveTasks
        write 'exit'
        exit
    end

    def inputHandler type, data
        case type
        when 'new'
            url = data['url']
            path = data['path']
            newTask path, url
        when 'start'
            id = data['id'].to_i
            startTask id
        when 'suspend'
            id = data['id'].to_i
            suspendTask id
        when 'delete'
            id = data['id'].to_i
            deleteTask id
        when 'connect'
            ipAddr = data['ipAddr']
            connect ipAddr
        when 'fetchInfo'
            sendInfo
        when 'exit'
            finalize
        end
    end
end
