require './JsonOutputStream'

class MyOutputStream
    def initialize output
        @output = JsonOutputStream.new output
    end

    def write type, data
        jsonData = {
            'type' => type
        }
        data.each do |key, value|
            jsonData[key] = value
        end
        @output.write jsonData
    end
end
