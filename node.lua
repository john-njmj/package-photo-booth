gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local font = resource.load_font "font.ttf"
local overlay = resource.create_colored_texture(0,0,0,0)
local dynamic

local mode = "loop"
local ren_nr = "0"
local ren_nr_state = "none"
local playlist = {}

util.json_watch("config.json", function(config)
    print "updated config"
    local new_playlist = {}
    for idx, item in ipairs(config.playlist) do
        new_playlist[idx] = {
            file = resource.open_file(item.file.asset_name),
            type = item.file.type,
            duration = item.duration,
        }
    end
    overlay:dispose()
    overlay = resource.load_image(config.collage_overlay.asset_name)
    playlist = new_playlist
end)

local function Player()
    local cur = resource.create_colored_texture(0, 0, 0, 0)
    local idx = 0
    local ends = 0
    local nxt, nxt_duration

    local function load_next()
        idx = idx % #playlist + 1
        if not playlist[idx] then
            return resource.create_colored_texture(0, 0, 0, 0)
        elseif playlist[idx].type == "video" then
            return resource.load_video{
                file = playlist[idx].file:copy(),
                raw = true,
            }, playlist[idx].duration
        else
            return resource.load_image{
                file = playlist[idx].file:copy(),
            }, playlist[idx].duration
        end
    end

    local function tick()
        if sys.now() >= ends and not nxt then
            nxt, nxt_duration = load_next()
        end

        if nxt then
            local state = nxt:state()
            if state == "loaded" then
                ends = sys.now() + nxt_duration
                local old
                nxt, cur, old = nil, nxt, cur
                old:dispose()
            end
        end

        if type(cur) == "image" then
            cur:draw(0, 0, WIDTH, HEIGHT)
        else
            cur:place(0, 0, WIDTH, HEIGHT):layer(1)
        end
    end

    local function stop()
        cur:dispose()
        cur = resource.create_colored_texture(0, 0, 0, 0)
        if nxt then
            nxt:dispose()
            nxt = nil
        end
        ends = 0
    end

    return {
        tick = tick;
        stop = stop;
    }
end

local player = Player()

local function text_center(y, text, size, r,g,b,a)
    local width = font:width(text, size)
    return font:write((WIDTH-width)/2, y-size/2, text, size, r,g,b,a)
end

local function text_renner(y, text, size, r,g,b,a)
    local width = font:width(text, size)
    return font:write(100, y-size, text, size, r,g,b,a)
end
local countdown, countdown_end, pic_num
local pictures

util.data_mapper{
    photomode = function()
        player:stop()
        mode = "photomode"
    end;
    snap = function(info)
        mode = "snap"
        local seconds
        pic_num, seconds = string.match(info, "(.*),(.*)")
        countdown = tonumber(seconds)
        countdown_end = sys.now() + countdown
    end;
    collage = function()
        pictures = {
            resource.load_image "picture1.jpg",
            resource.load_image "picture2.jpg",
            resource.load_image "picture3.jpg",
            resource.load_image "picture4.jpg",
        }
        mode = "collage"
    end;
    loop = function()
        mode = "loop"
    end;
    renner_nr = function(info)
        ren_nr = info
        ren_nr_state = "Test"
        if len(ren_nr) == 3 then
           ren_nr_state = "Renner"
        else 
           ren_nr_state = "Input"
        end
    end;
    
}

-- Handle loading/unloading of dynamic server response
node.event("content_update", function(filename, file)
    if filename == "dynamic.png" then
        dynamic = resource.load_image(file)
    end
end)

node.event("content_remove", function(filename)
    if filename == "dynamic.png" and dynamic then
        dynamic:dispose()
        dynamic = nil
    end
end)

function node.render()
    if mode == "loop" then
        gl.clear(0, 0, 0, 0)
        -- player.tick()
        local size = math.ceil(HEIGHT/10)
        text_renner(HEIGHT-50, ren_nr, size, 1,1,1,1)
        text_renner(HEIGHT-200, ren_nr_state, size, 1,1,1,1)
    elseif mode == "snap" then
        local remaining = math.max(0, countdown_end - sys.now())

        -- Flash effect
        local flash = math.max(0, 1-remaining*5)
        gl.clear(1, 1, 1, 0)

        -- Info Text
        local size = math.ceil(HEIGHT/10)
        local mid = HEIGHT/2
        text_center(mid - size, string.format("Photo %d of 4", pic_num), size, 1,1,1,.5)
        text_renner(HEIGHT, ren_nr , size, 1,1,1,1)
        if remaining > 0 then
            -- text_center(mid, string.format("%.2f", remaining), size/2, 1,1,1,1)
        else
            text_center(mid, "Taking Picture", size/2, 0,0,0,1)
        end
        text_center(mid + size, string.format("Look at Me", pic_num), size, 1,1,1,.5)

        -- Progress Slider
        local progress = WIDTH/2 - WIDTH/2 / countdown * remaining
        black:draw(0, mid-size/2, WIDTH, mid+size/2, 0.1)
        white:draw(0, mid-size/2, progress, mid+size/2, 0.2)
        white:draw(WIDTH, mid-size/2, WIDTH-progress, mid+size/2, 0.2)
        text_renner(HEIGHT, string.format("%d", ren_nr), size, 1,1,1,1)
    elseif mode == "collage" then
        local w = WIDTH/2
        local h = HEIGHT/2
        for pic_num = 1, 4 do
            local x = (pic_num-1)%2 * w
            local y = math.floor((pic_num-1)/2) * h
            pictures[pic_num]:draw(x, y, x+w, y+h)
        end
        overlay:draw(0, 0, WIDTH, HEIGHT)
        if dynamic then
            dynamic:draw(0, 0, WIDTH, HEIGHT)
        end
    end
end
