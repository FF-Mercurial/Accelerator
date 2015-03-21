require './Master'

class MasterManager
    def initialize
        @masters = []
    end

    def include? ipAddr
        @masters.each do |master|
            return true if ipAddr == master.ipAddr
        end
        return false
    end

    def newMaster socket
        master = Master.new self, socket
        @masters << master
    end

    def removeMaster master
        master.remove
        @masters.delete master
    end

    def removeAll
        @masters.each do |master|
            removeMaster master
        end
    end
end
