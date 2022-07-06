util.init_hosted()

-- this is only supported on the Raspi....
--util.noglobals()

node.set_flag("no_clear")

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local modf = math.modf
local font = resource.load_font("ubuntu.ttf")

-- persistent state, survives file reloads
local state = rawget(_G, "._state")
if not state then
    state = {}
    state.baseTime = 0
    state.timeH = nil
    state.timeM = nil
    state.timeS = nil
    state.lastTimeUpdate = 0
    rawset(_G, "._state", state)
end

util.data_mapper{
    ["clock/set"] = function(tm)
        updateTime(tm)
    end,
}




function getWallClockTime()
    local now = sys.now()
    return state.baseTime + now, now - state.lastTimeUpdate
end

-- interpolates since last update received
function getWallClockTimeString()
    local h, m, s = state.timeH, state.timeM, state.timeS
    if not (h and m and s) then
        return "--:--:--"
    end

    local overflow = sys.now() - state.lastTimeUpdate
    local si = math.floor(((s + overflow) % 60))
    overflow = (s + overflow) / 60
    local mi = math.floor((m + overflow) % 60)
    overflow = (m + overflow) / 60
    local hi = math.floor((h + overflow) % 24)

    return ("%02d:%02d:%02d"):format(hi, mi, si)
end

function updateTime(tm)
    local now = sys.now() -- this is relative to the start of info-beamer
    state.lastTimeUpdate = now

    local u, h, m, s = tm:match("([%d%.]+),(%d+),(%d+),([%d%.]+)")
    state.baseTime = tonumber(u) - now
    state.timeH = tonumber(h)
    state.timeM = tonumber(m)
    state.timeS = tonumber(s)

    tools.debugPrint(4, "updated base time: " .. state.baseTime .. ", it's now: " ..
                         state.getWallClockTimeString() .. " (" ..  state.getWallClockTime() .. ")")
end


local function drawtime(size)
   timestr = getWallClockTimeString()
   w = font:width(timestr, size)
   font:write(WIDTH/2 -w/2, HEIGHT/2 - size/2, timestr, size, 1,1,1,1)
end

function node.render()
    aspect = aspect or (WIDTH / HEIGHT)
    gl.clear(0.0, 0.0, 0.0, 1.0)
    gl.ortho()
    drawtime(HEIGHT/5)
end
