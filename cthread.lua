-- CThreads Module
-- cthread.lua - Coroutine Threads in Pure Lua
-- (c) 2025 Sibot
-- Licensed under the MIT License
local function coro(func)
  return function(...)
    func(...)
    coroutine.yield()
  end
end

local cthread = {}
cthread.list = {}
cthread.queue = {}

local function _trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function _strip_comment(line)
  return (line:gsub("%-%-.*$", ""))
end

local function _is_blank_or_comment(line)
  local s = _trim(_strip_comment(line))
  return s == ""
end

local function _is_func_start(s)
  return s:match("^function%s") or s:match("^local%s+function%s") or s:match("=%s*function%s*%(")
end

local function _is_func_end(s)
  return s == "end"
end

local function _is_control_head(s)
  if s:match("^if%s") or s:match("^for%s") or s:match("^while%s") or s:match("^repeat%s*$") then
    return true
  end
  if s == "do" or s == "else" or s:match("^elseif%s") or s:match("^until%s") then
    return true
  end
  return false
end

local function _has_coronized_call(s)
  if s:find("%f[%w_]print%f[^%w_]") or s:find("%f[%w_]sleep%f[^%w_]") then
    return true
  end
  return false
end

local function _needs_injection(stmt)
  local s = _trim(_strip_comment(stmt))
  if s == "" then return false end
  if _is_control_head(s) then return false end
  if s:match("^return") or s:match("^break") or s == "end" then return false end
  if _has_coronized_call(s) then return false end
  return true
end

local function inject_yields(code)
  local out = {}
  local in_func = false

  for rawline in (code.."\n"):gmatch("([^\r\n]*)\r?\n") do
    local line = rawline
    local s = _trim(_strip_comment(line))

    if _is_func_start(s) then
      table.insert(out, line)
      if not s:find("end%s*$") then in_func = true end
    elseif in_func then
      table.insert(out, line)
      if _is_func_end(s) then in_func = false end
    else
      if _is_blank_or_comment(line) or _is_control_head(s) or s == "end" then
        table.insert(out, line)
      else
        local any_semicolon = line:find(";")
        if any_semicolon then
          local body = _strip_comment(line)
          local first = true
          for part in body:gmatch("([^;]+)") do
            local stmt = _trim(part)
            if stmt ~= "" then
              table.insert(out, stmt)
              if _needs_injection(stmt) then
                table.insert(out, "sleep(0)")
              end
            end
            first = false
          end
        else
          table.insert(out, line)
          if _needs_injection(line) then
            table.insert(out, "sleep(0)")
          end
        end
      end
    end
  end

  return table.concat(out, "\n")
end

cthread.env = {
print = coro(print)
  cthread = {
    new = coro(cthread.new),
    push = coro(cthread.push),
    start = coro(cthread.start)
  },
  sleep = coro(function(t)
    t = tonumber(t) or 0
    if t <= 0 then
      return coroutine.yield()
    end
    local target = os.clock() + t
    repeat
      coroutine.yield()
    until os.clock() >= target
  end)
}

function cthread.new(name, code)
  local transformed = inject_yields(code)
  local chunk, err = load(transformed, name, "t", cthread.env)
  if not chunk then error("CThread Load Error '"..name.."': "..err) end
  cthread.list[name] = coroutine.create(chunk)
end

function cthread.push(name)
  cthread.queue[#cthread.queue+1] = name
end

function cthread.tick()
  local q = cthread.queue
  cthread.queue = {}
  for i = 1, #q do
    local name = q[i]
    local co = cthread.list[name]
    if co and coroutine.status(co) ~= "dead" then
      local ok, res = coroutine.resume(co)
      if not ok then
        print("CThread Runtime Error: "..name..":"..tostring(res))
      elseif coroutine.status(co) ~= "dead" then
        cthread.queue[#cthread.queue+1] = name
      end
    end
    q[i] = nil
  end
end

function cthread.start()
  while #cthread.queue > 0 do
    cthread.tick()
  end
end

cthread.mail = cthread.mail or {}

local _unpack = table.unpack or unpack
local function _current_thread_name()
  local this = coroutine.running()
  for name, co in pairs(cthread.list) do
    if co == this then return name end
  end
  return "<?>"
end
local function _ensure_box(name)
  local box = cthread.mail[name]
  if not box then
    box = {}
    cthread.mail[name] = box
  end
  return box
end

cthread.env.send = function(dst, key, ...)
  if type(dst) ~= "string" then error("send: dst must be a thread name (string)") end
  local from = _current_thread_name()
  local box = _ensure_box(dst)
  box[#box+1] = { from = from, key = key, args = { ... } }
  return true
end

cthread.env.collect = function(from, key)
  local me = _current_thread_name()
  local box = _ensure_box(me)
  if #box == 0 then return nil end
  for i, msg in ipairs(box) do
    local ok_from = (from == nil) or (msg.from == from)
    local ok_key  = (key  == nil) or (msg.key  == key)
    if ok_from and ok_key then
      table.remove(box, i)
      return msg.from, msg.key, _unpack(msg.args)
    end
  end
  return nil
end

local function cthread.used(func, ...)
  collectgarbage("collect")
  local start = os.clock()
  local result = table.pack(func(...))
  local finish = os.clock()
  result.cpu = tonumber(("%.3f"):format(finish - start)) 
  return result
end
print(res.cpu)
print(collectgarbage("count"))
return cthread
