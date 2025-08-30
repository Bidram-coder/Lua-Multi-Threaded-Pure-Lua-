--Example
-- cthread.lua - Coroutine Threads in Pure Lua
-- (c) 2025 Sibot
-- Licensed under the MIT License
local API = require("cthread")
API.cthread.new("Alpha", [[
print("Alpha Begin")
for i = 1, 3 do
  print("Alpha step", i)
  send("Beta", { key="step", value=i })
end
print("Alpha End")
]])
API.cthread.new("Beta", [[
print("Beta Begin")
wait(0.00001)
local msgs = collect("Alpha", "step")
for _, m in ipairs(msgs) do
  print("Beta got step:", m.msg.value)
end
for x = 1, 2 do
  print("Beta loop", x)
end
print("Beta Done")
]])

API.cthread.push("Alpha")
API.cthread.push("Beta")
API.cthread.start()
