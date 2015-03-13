require './JsonInputStream'
require './JsonOutputStream'
require './LocalTaskManager'
require 'json'

class Controller
    def initialize
        @output = JsonOutputStream.new STDOUT
        @ltm = LocalTaskManager.new
        @stms = []
        @input = JsonInputStream.new STDIN do |jsonData|
            inputHandler jsonData
        end
    end

    def inputHandler jsonData
        case jsonData['type']
        when 'new'
            url = jsonData['url']
            path = jsonData['path']
            @ltm.newTask path, url
        when 'start'
            id = jsonData['id'].to_i
            @ltm.startTask id
        when 'suspend'
            id = jsonData['id'].to_i
            @ltm.suspendTask id
        when 'delete'
            id = jsonData['id'].to_i
            @ltm.deleteTask id
        when 'info'
            data = {
                'type' => 'info',
                'info' => {
                    'tasks' => @ltm.tasks
                }
            }
            @output.write data
        when 'exit'
            @ltm.saveTasks
            data = {
                'type' => 'exit'
            }
            @output.write data
            exit
        end
    end

    def write jsonData
        @output.write jsonData
    end
end
