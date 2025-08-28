-- CThreads Module
-- cthread.lua - Coroutine Threads in Pure Lua
-- (c) 2025 Sibot
-- Licensed under the MIT License
local clock         = os.clock
local insert        = table.insert
local remove        = table.remove
local resume        = coroutine.resume
local status        = coroutine.status
local yield         = coroutine.yield
local function yield_after(fn, tag)
  tag = tag or "Yield-after-call"
  return function(...)
    fn(...)
    return yield(tag)
  end
end
local cthread = {
  threads = {},
  queue   = {},
}
local function enqueue(th)
  if not th.inq and status(th.co) ~= "dead" then
    th.inq = true
    insert(cthread.queue, th.name)
  end
end
local function make_thread_env(th)
  local function send(to, msg)
    local dst = cthread.threads[to]
    if not dst then return false, "no such thread: "..tostring(to) end
    local box = dst.inbox
    box[#box+1] = {
      from = th.name,
      to   = to,
      ts   = clock(),
      msg  = msg,
    }
    return true
  end
  local function collect(from, key_or_pred)
    local inbox = th.inbox
    if #inbox == 0 then return {} end
    local out, keep = {}, {}
    local pred
    if type(key_or_pred) == "function" then
      pred = key_or_pred
    elseif key_or_pred ~= nil then
      local key = key_or_pred
      pred = function(m)
        local t = m.msg
        return type(t) == "table" and t.key == key
      end
    else
      pred = function(_) return true end
    end
    for i = 1, #inbox do
      local m = inbox[i]
      if (from == nil or m.from == from) and pred(m) then
        out[#out+1] = m
      else
        keep[#keep+1] = m
      end
    end
    th.inbox = keep
    return out
  end
  local function wait(seconds)
    seconds = tonumber(seconds) or 0
    th.wake = clock() + seconds
    return yield("sleep")
  end
  local env = {
    print     = yield_after(_G.print, "print"),
    wait      = wait,
    send      = send,
    collect   = collect,
    tostring  = tostring,
    tonumber  = tonumber,
    math      = math,
    string    = string,
    table     = { insert = table.insert, remove = table.remove, sort = table.sort, concat = table.concat },
    pairs     = pairs, ipairs = ipairs, next = next,
  }
  return env
end
function cthread.kill(name)
  cthread.threads[name] = nil
end
function cthread.new(name, code)
  assert(type(name) == "string" and name ~= "", "name required")
  assert(type(code) == "string" and code ~= "", "code (string chunk) required")
  if cthread.threads[name] then error("thread exists: "..name) end
  local th = { name = name, inbox = {}, wake = 0.0, inq = false }
  local env = make_thread_env(th)
  local chunk, err = load(code, name, "t", env)
  if not chunk then error(("CThread Load Error '%s': %s"):format(name, err)) end
  th.co = coroutine.create(chunk)
  cthread.threads[name] = th
  return th
end
function cthread.push(name)
  local th = cthread.threads[name]
  if not th then error("no such thread: "..tostring(name)) end
  enqueue(th)
end
function cthread.tick()
  local now = clock()
  local q = cthread.queue
  cthread.queue = {}
  for i = 1, #q do
    local name = q[i]
    local th = cthread.threads[name]
    if th then th.inq = false end

    if th and status(th.co) ~= "dead" then
      if th.wake > now then
        enqueue(th)
      else
        local ok, res = resume(th.co)
        if not ok then
          _G.print(("CThread Runtime Error %s: %s"):format(name, tostring(res)))
        else
          if status(th.co) ~= "dead" then
            enqueue(th)
          end
        end
      end
    end
  end
end
function cthread.start()
  while #cthread.queue > 0 do
    cthread.tick()
  end
end
return cthread
