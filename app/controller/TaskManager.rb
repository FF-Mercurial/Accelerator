class TaskManager
    def initialize
        @tasks = {}
    end

    def deleteTask id
        @tasks[id].delete
        @tasks.delete id
    end
end
