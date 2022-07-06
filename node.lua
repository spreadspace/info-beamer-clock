util.init_hosted()

-- this is only supported on the Raspi....
--util.noglobals()

node.set_flag("no_clear")

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local modf = math.modf

local font = resource.load_font("ubuntu.ttf")

local function drawtime(now, size)
   local th, tm, ts, tms
   th, tm = modf(now/3600)
   tm, ts = modf(tm*60)
   ts, tms = modf(ts*60)
   tms = tms*1000
   timestr = string.format("%02d:%02d:%02d.%03d", th, tm, ts, tms)
   w = font:width(timestr, size)
   font:write(WIDTH/2 -w/2, HEIGHT/2 - size/2, timestr, size, 1,1,1,1)
end

function node.render()
    aspect = aspect or (WIDTH / HEIGHT)
    local now = sys.now()
    gl.clear(0.0, 0.0, 0.0, 1.0)
    gl.ortho()
    drawtime(now, HEIGHT/10)
end
