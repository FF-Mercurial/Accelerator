require './MyInputStream'
require './MyOutputStream'
require './LocalTaskManager'
require 'json'

class Controller
    def initialize
        @output = MyOutputStream.new STDOUT
        @ltm = LocalTaskManager.new
        @stms = []
        @input = MyInputStream.new STDIN do |type, data|
            inputHandler type, data
        end
    end

    def write type, data = {}
        @output.write type, data
    end

    def inputHandler type, data
        case type
        when 'new'
            url = data['url']
            path = data['path']
            @ltm.newTask path, url
        when 'start'
            id = data['id'].to_i
            @ltm.startTask id
        when 'suspend'
            id = data['id'].to_i
            @ltm.suspendTask id
        when 'delete'
            id = data['id'].to_i
            @ltm.deleteTask id
        when 'fetchInfo'
            data = {
                'info' => {
                    'tasks' => @ltm.tasks
                }
            }
            write 'info', data
        when 'exit'
            @ltm.saveTasks
            write 'exit'
            exit
        end
    end
end
