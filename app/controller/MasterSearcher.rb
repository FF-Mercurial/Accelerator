require './ServerSearcher'

class MasterSearcher < ServerSearcher
    def initialize controller
        @controller = controller
        super()
    end

    def serverFound ipAddr
        @controller.connect ipAddr
    end
end
