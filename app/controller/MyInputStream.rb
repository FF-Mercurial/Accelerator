require './JsonInputStream'

class MyInputStream
    def initialize input
        @jsonInputStream = JsonInputStream.new input do |jsonData|
            type = jsonData['type']
            data = jsonData
            data.delete 'type'
            yield type, data
        end
    end

    def stopReading
        @jsonInputStream.stopReading
    end
end
