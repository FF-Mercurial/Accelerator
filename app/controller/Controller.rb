require './MyInputStream'
require './MyOutputStream'
require './LocalTaskManager'
require './SupporterManager'
require './MasterManager'
require './SupporterListener'
require './MasterSearcher'
require './SupporterSearcher'
require './Util'

class Controller
    include Constants
    
    def initialize
        @ltm = LocalTaskManager.new
        @stms = []
        @sm = SupporterManager.new @ltm
        @sl = SupporterListener.new @sm
        @ss = SupporterSearcher.new
        openSupporter
        @output = MyOutputStream.new STDOUT
        @input = MyInputStream.new STDIN, true do |type, data|
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
        @sm.deleteTask id
        @ltm.suspendTask id
    end

    def deleteTask id
        @sm.deleteTask id
        @ltm.deleteTask id
    end

    def connect ipAddr
        return if @mm.include? ipAddr
        socket = TCPSocket.new ipAddr, MASTER_PORT
        @mm.newMaster socket
    end

    def sendInfo
        data = {
            'info' => {
                'tasks' => @ltm.tasksInfo,
                'supportersNum' => @sm.supportersNum,
                'supporterState' => @mm != nil
            }
        }
        write 'info', data
    end

    def openSupporter
        return if @mm != nil
        @mm = MasterManager.new
        @ms = MasterSearcher.new self
    end

    def closeSupporter
        @ms.close
        @mm.removeAll
        @ms = nil
        @mm = nil
    end

    def finalize
        @sm.deleteAll
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
        when 'openSupporter'
            openSupporter
        when 'closeSupporter'
            closeSupporter
        when 'fetchInfo'
            sendInfo
        when 'exit'
            finalize
        end
    end
end
