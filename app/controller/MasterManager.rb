require './Master'

class MasterManager
    def initialize
        @masters = []
    end

    def newMaster socket
        master = Master.new socket
        @masters << master
    end
end
