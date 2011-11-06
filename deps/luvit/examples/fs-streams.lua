local FS = require('fs')

print("Reading file as stream")
local stream = FS.create_read_stream("TODO.markdown")

print("Adding data listener")
stream:on('data', function (chunk, len)
  p("on_data", chunk, len)
end)

print("Adding end listener")
stream:on('end', function ()
  p("on_end")
end)

print("Adding close listener")
stream:on('close', function ()
  p("on_close")
end)
