-- CThreads Module
-- cthread.lua - Coroutine Threads in Pure Lua
-- (c) 2025 Sibot
-- Licensed under the MIT License
local function coro(func)
  return function(...)
    local result = table.pack(func(...))
    coroutine.yield()
    return table.unpack(result, 1, result.n)
  end
end

local cthread = {}
cthread.list = {}
cthread.queue = {}
cthread.sleeping = {}
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
    assert          = coro(assert),
    collectgarbage  = coro(collectgarbage),
    dofile          = coro(dofile),
    error           = coro(error),
    _G              = _G,
    getmetatable    = coro(getmetatable),
    ipairs          = coro(ipairs),
    load            = coro(load),
    loadfile        = coro(loadfile),
    next            = coro(next),
    pairs           = coro(pairs),
    pcall           = coro(pcall),
    print           = coro(print),
    rawequal        = coro(rawequal),
    rawget          = coro(rawget),
    rawlen          = coro(rawlen),
    rawset          = coro(rawset),
    require         = coro(require),
    select          = coro(select),
    setmetatable    = coro(setmetatable),
    tonumber        = coro(tonumber),
    tostring        = coro(tostring),
    type            = coro(type),
    xpcall          = coro(xpcall),
    table = {
        concat  = coro(table.concat),
        insert  = coro(table.insert),
        move    = coro(table.move),
        pack    = coro(table.pack),
        remove  = coro(table.remove),
        sort    = coro(table.sort),
        unpack  = coro(table.unpack),
    },
    math = {
        abs       = coro(math.abs),
        acos      = coro(math.acos),
        asin      = coro(math.asin),
        atan      = coro(math.atan),
        ceil      = coro(math.ceil),
        cos       = coro(math.cos),
        deg       = coro(math.deg),
        exp       = coro(math.exp),
        floor     = coro(math.floor),
        fmod      = coro(math.fmod),
        huge      =  "inf",
        log       = coro(math.log),
        max       = coro(math.max),
        min       = coro(math.min),
        modf      = coro(math.modf),
        pi        =  3.14159265359,
        rad       = coro(math.rad),
        random    = coro(math.random),
        randomseed= coro(math.randomseed),
        sin       = coro(math.sin),
        sqrt      = coro(math.sqrt),
        tan       = coro(math.tan),
        tointeger = coro(math.tointeger),
        type      = coro(math.type),
        ult       = coro(math.ult),
    },
    string = {
        byte     = coro(string.byte),
        char     = coro(string.char),
        dump     = coro(string.dump),
        find     = coro(string.find),
        format   = coro(string.format),
        gmatch   = coro(string.gmatch),
        gsub     = coro(string.gsub),
        len      = coro(string.len),
        lower    = coro(string.lower),
        match    = coro(string.match),
        pack     = coro(string.pack),
        packsize = coro(string.packsize),
        rep      = coro(string.rep),
        reverse  = coro(string.reverse),
        sub      = coro(string.sub),
        unpack   = coro(string.unpack),
        upper    = coro(string.upper),
    },
    utf8 = {
        char        = coro(utf8.char),
        codepoint   = coro(utf8.codepoint),
        codes       = coro(utf8.codes),
        len         = coro(utf8.len),
        offset      = coro(utf8.offset),
    },
    coroutine = {
        close       = coro(coroutine.close),
        create      = coro(coroutine.create),
        isyieldable = coro(coroutine.isyieldable),
        resume      = coro(coroutine.resume),
        running     = coro(coroutine.running),
        status      = coro(coroutine.status),
        wrap        = coro(coroutine.wrap),
        yield       = coro(coroutine.yield),
    },
    debug = {
        debug        = coro(debug.debug),
        gethook      = coro(debug.gethook),
        getinfo      = coro(debug.getinfo),
        getlocal     = coro(debug.getlocal),
        getmetatable = coro(debug.getmetatable),
        getregistry  = coro(debug.getregistry),
        getupvalue   = coro(debug.getupvalue),
        getuservalue = coro(debug.getuservalue),
        sethook      = coro(debug.sethook),
        setlocal     = coro(debug.setlocal),
        setmetatable = coro(debug.setmetatable),
        setupvalue   = coro(debug.setupvalue),
        setuservalue = coro(debug.setuservalue),
        traceback    = coro(debug.traceback),
        upvalueid    = coro(debug.upvalueid),
        upvaluejoin  = coro(debug.upvaluejoin),
    },

    io = {
        close    = coro(io.close),
        flush    = coro(io.flush),
        input    = coro(io.input),
        lines    = coro(io.lines),
        open     = coro(io.open),
        output   = coro(io.output),
        popen    = coro(io.popen),
        read     = coro(io.read),
        tmpfile  = coro(io.tmpfile),
        type     = coro(io.type),
        write    = coro(io.write),
    },
    os = {
        clock     = coro(os.clock),
        date      = coro(os.date),
        difftime  = coro(os.difftime),
        execute   = coro(os.execute),
        exit      = coro(os.exit),
        getenv    = coro(os.getenv),
        remove    = coro(os.remove),
        rename    = coro(os.rename),
        setlocale = coro(os.setlocale),
        time      = coro(os.time),
        tmpname   = coro(os.tmpname),
    },
    package = {
        config      = package.config,
        cpath       = package.cpath,
        loaded      = package.loaded,
        loadlib     = coro(package.loadlib),
        path        = package.path,
        preload     = package.preload,
        searchers   = package.searchers,
        searchpath  = coro(package.searchpath),
    },
  sleep = coro(function(t)
    t = tonumber(t) or 0
    if t <= 0 then
      return coroutine.yield()
    end
    local target = os.clock() + t
    local current = coroutine.running()
    for name, co in pairs(cthread.list) do
      if co == current then
        cthread.sleeping[name] = target
        return coroutine.yield()
      end
    end
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
  local now = os.clock()
  for name, wake in pairs(cthread.sleeping) do
    if now >= wake then
      cthread.queue[#cthread.queue+1] = name
      cthread.sleeping[name] = nil
    end
  end
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
local _unpack = table.unpack
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

local function used(func, ...)
  collectgarbage("collect")
  local start = os.clock()
  local result = table.pack(func(...))
  cthread.start()
  local finish = os.clock()
  result.cpu = tonumber(("%.4f"):format(finish - start))
  return result
end
cthread.env["cthread"] = {}
cthread.env.cthread["push"] = coro(cthread.push)
cthread.env.cthread["new"] = coro(cthread.new)
cthread.env.cthread["start"] = coro(cthread.start)
-- Example
local res = used(function()
cthread.new("ping", [=[
  cthread.new("pong", [[ print(math.pi)
  print(math.huge)
  print(math.sin(21))]])
  cthread.push("pong")
  cthread.start()
]=])
cthread.push("ping")
cthread.start()
end)
print(res.cpu)
print(collectgarbage("count"))
