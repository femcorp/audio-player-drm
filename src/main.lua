local DiscordHook = require("lib/DiscordHook")
local webify = require("lib/webify")
local app = webify()
local hashes = settings.get("server.hashes",{})
local nicks = {[3858] = "Dev PC",[3925] = "BlackDragon_B", [3959] = "StealthyCoder",[3983] = "PatriikPlays",[3958] = "diamondporkchop"}

local success, hook = DiscordHook.createWebhook("https://discord.com/api/webhooks/1104780495071482087/wnPOQOem7_3OBDdFaMaTs7GXFMP8_0cVHVis6ovZsDc1rCumC62ujnZUCPULWQhVySfO")
if not success then
  error("Webhook connection failed! Reason: " .. hook)
end

app.addMiddleware(function(req,res) 
  print("Got request for " .. req.getURL())
end)

app.post("/check", function(req,res)
  if req.body then
    if req.json.hash then
        req.json.id = req.json.id or "Old version, no ID"
        req.json.debugEnabled = req.json.debugEnabled or "Old version, no debug info"
        local nick = nicks[req.json.id] or "No Nickname"
        if hashes[req.json.hash] then
            res.write(textutils.serialiseJSON({status = "ok"}))
            res.close()
            return
        else
            res.write(textutils.serialiseJSON({status = "invalid"}))
            res.close()
            hook.send("Got hash violation for hash `" .. req.json.hash .. "`" .. "\n ID: " .. req.json.id .. "\n Nickname: " .. nick .. "\n Debug: " .. tostring(req.json.debugEnabled))
            return
        end
    end
  end
  res.write(textutils.serialiseJSON({status = "error"}))
            res.close()
end)

app.post("/add", function(req,res)
    if req.json and req.json.key == "$Mh6HR9F@cCV6KdJY3jve4xD6BD#vfHqdCBbny5hM&F^EWbGUiXvHzJLq" and req.json.hash then
        hashes[req.json.hash] = true
        settings.set("server.hashes",hashes)
        settings.save()
        hook.send("Hash `" .. req.json.hash .. "` got added")
        res.write("OK")
        res.close()
    end
end)

app.get("/",function(req,res) 
    local filesToCheck = {"player.lua","setup.lua","/lib/common.lua","/lib/bigfont","/lib/libMDFPWM.lua","/lib/sha256.lua","startup.lua","lib/dfpwm.lua","lib/selection.lua"}
    return textutils.serialiseJSON(filesToCheck)
end)

print("Listening on 6699")

app.run(6699)