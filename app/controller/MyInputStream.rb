require './JsonInputStream'

class MyInputStream
    def initialize input, sync = false
        @jsonInputStream = JsonInputStream.new input, sync do |jsonData|
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
