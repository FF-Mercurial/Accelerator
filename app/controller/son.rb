require './StringInputStream'
require './StringOutputStream'

loop do
    begin
        STDIN.read_nonblock 1024
    rescue
    end
end
