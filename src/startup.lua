print("STARTUP RAN")
_G.error = function()
  os.reboot()
end
shell.run("main.lua")