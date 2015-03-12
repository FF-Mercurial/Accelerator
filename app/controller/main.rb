require './Controller'

$controller = Controller.new

# for debuging
def log msg
    jsonData = {
        'type' => 'log',
        'msg' => msg
    }
    $controller.write jsonData
end

# loop do
    # sleep 0.1
    # log 'hello'
# end
