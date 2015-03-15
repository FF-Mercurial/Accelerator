require './MyInputStream'
require './MyOutputStream'

class Supporter
    def initialize socket
        @socket = socket
        Thread.new do
            @input = MyInputStream.new socket do |type, data|
                inputHandler type, date
            end
        end
        @output = MyOutputStream.new socket
    end

    def write type, data
        @output.write type, data
    end

    def newTask id, url
        write 'new', {
            'id' => id,
            'url' => url
        }
    end

    def deleteTask id
        write 'delete', {
            'id' => id
        }
    end

    def sendPart
        write 'part', {
            'part' => 
        }
    end

    def inputHandler type, data
        
    end
end
