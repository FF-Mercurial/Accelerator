require 'thread'

require './Controller'

lock = Mutex.new

controller = Controller.new
