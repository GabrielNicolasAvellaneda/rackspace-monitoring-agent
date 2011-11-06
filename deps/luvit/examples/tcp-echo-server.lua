local TCP = require('tcp')

local server = TCP.create_server("0.0.0.0", 8080, function (client)
  p("on_connection", client)

  print("Adding listener for data events")
  client:on("data", function (chunk)
    p("on_read", chunk)
    
    print("Sending chunk back to client")
    client:write(chunk, function (err)
      p("on_written", err)
    end)

  end)
  
  print("Adding listener for close event")
  client:on("end", function ()
    p("on_end")
    
    print("Closing connection")
    client:close(function ()
      p("on_closed")
    end)
  end)
  
end)

print("Listening for errors in the server")
server:on("error", function (err)
  p("ERROR", err)
end)

print("TCP echo server listening on port 8080")

