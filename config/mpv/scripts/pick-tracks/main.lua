-- Japanese audio + full English subs whenever a file has Japanese audio.
-- Plain alang/slang can't do this: releases often flag a "Signs" track as the
-- default English sub, which mpv would pick. Logic lives in choose.lua.
package.path = mp.get_script_directory() .. "/?.lua;" .. package.path
local choose = require("choose")
local msg = require("mp.msg")

mp.register_event("file-loaded", function()
  local aid, sid = choose.pick(mp.get_property_native("track-list") or {})
  if aid then mp.set_property_native("aid", aid) end
  if sid then mp.set_property_native("sid", sid) end
  msg.info(("aid=%s sid=%s"):format(tostring(aid), tostring(sid)))
end)
