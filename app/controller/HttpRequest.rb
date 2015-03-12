require 'socket'

class HttpRequest
    class << self
        # parse a url and extract the host and path
        def parseUrl url
            # remove http://
            url = url[7..-1] if url =~ /^http:\/\//
            sep = url.index '/'
            return url, '/' if sep == nil
            host = url[0...sep]
            port = 80
            colon = host.index ':'
            if colon != nil
                port = host[colon + 1..-1].to_i
                host = host[0...colon]
            end
            path = url[sep..-1]
            return host, port, path
        end

        def pushLine msg, line
            msg << line + "\r\n"
        end

        def createRequest method, host, path, headers = {}
            msg = ''
            pushLine msg, "#{method} #{path} HTTP/1.1"
            headers.each do |key, value|
                pushLine msg, "#{key}: #{value}"
            end
            pushLine msg, "Host: #{host}"
            pushLine msg, "Connection: close"
            pushLine msg, ""
            msg
        end

        def parseResponse socket
            statusLine = socket.readline "\r\n"
            status = statusLine.match(/\d\d\d/)[0].to_i
            headers = {}
            loop do
                line = socket.readline "\r\n"
                line = line[0...-2]
                break if line.length == 0
                sep = line.index ':'
                key = line[0...sep]
                value = line[sep + 1..-1]
                # key转小写
                headers[key.downcase] = value.lstrip
            end
            return status, headers
        end

        def getLength url
            host, port, path = parseUrl url
            msg = createRequest 'HEAD', host, path
            socket = TCPSocket.new host, port
            socket.write msg
            status, headers = parseResponse socket
            socket.close
            headers['content-length'].to_i
        end
        
        def get url, range = nil
            host, port, path = parseUrl url
            headers = {}
            headers['Range'] = "bytes=#{range.begin}-#{range.end}" if range != nil
            msg = createRequest 'GET', host, path, headers
            socket = TCPSocket.new host, port
            socket.write msg
            status, headers = parseResponse socket
            if range != nil
                if headers['content-length'].to_i != range.count
                    raise
                end
            end
            socket
        end
    end
end

# test
# url = 'http://dlsw.baidu.com:80/sw-search-sp/soft/4f/20605/BaiduType_Setup3.3.2.16.1827398843.exe'
# require './Part'
# part = Part.new 1, 100000
# HttpRequest.get url, part
