require './JsonInputStream'

class MyInputStream
    def initialize input
        @input = JsonInputStream.new input do |jsonData|
            type = jsonData['type']
            data = jsonData
            data.delete 'type'
            yield type, data
        end
    end
end
