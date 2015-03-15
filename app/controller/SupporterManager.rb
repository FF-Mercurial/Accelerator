require './Supporter'

class SupporterManager
    def initialize
        @supporters = []
    end

    def newSupporter socket
        @supporters << Supporter.new socket
    end

    def newTask id, url
        @supporters.each do |supporter|
            supporter.newTask id, url
        end
    end

    def deleteTask id
        @supporters.each do |supporter|
            supporter.deleteTask id
        end
    end
end
