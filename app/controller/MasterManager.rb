require './Master'

class MasterManager
    def initialize
        @masters = []
    end

    def newMaster socket
        master = Master.new self, socket
        @masters << master
    end

    def removeMaster master
        @masters.delete master
    end
end
