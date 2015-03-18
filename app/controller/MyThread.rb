class MyThread < Thread
    def initialize
        super
        at_exit do
            join
        end
    end
end
