class TaskManager
    def initialize
        @tasks = {}
    end

    def suspendTask id
        @tasks[id].suspend
    end

    def deleteTask id
        @tasks[id].delete
        @tasks.delete id
    end
end
