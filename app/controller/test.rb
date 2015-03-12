thread = Thread.new do
    Thread.current.stop
end
thread.join
