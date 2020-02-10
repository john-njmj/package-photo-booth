gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local t_font = resource.load_font "font.ttf"
local d_font = resource.load_font "font.ttf"
local t_text = "default title "
local racer_text = "default Racer "
local previous_text = "default Previous "
local racer_nr = "NR"
local racer_name = "Default Name "
local previous_pic = {}
local last_pic  = 1 
previous_pic[1] =  resource.create_colored_texture(0,1,1,1)
previous_pic[2] =  resource.create_colored_texture(1,0,1,1)
previous_pic[3] =  resource.create_colored_texture(1,1,0,1)

local dynamic

local mode = "wait"
local ren_nr = "0"
local ren_nr_state = "none"
local playlist = {}

util.json_watch("config.json", function(config)
    print "updated config"
--    overlay:dispose()
    t_font = resource.load_font(config.t_font.asset_name)
    d_font = resource.load_font(config.d_font.asset_name)
    t_text = config.t_text
    racer_text = config.racer_text
    previous_text = config.previous_text
end)

local function text_center(y, text, size, r,g,b,a)
    local width = d_font:width(text, size)
    return d_font:write((WIDTH-width)/2, y-size/2, text, size, r,g,b,a)
end

local function text_renner(y, text, size, r,g,b,a)
    local width = d_font:width(text, size)
    return d_font:write(100, y-size, text, size, r,g,b,a)
end

local countdown, countdown_end, pic_num
local pictures

util.data_mapper{
--    photomode = function()
--        mode = "photomode"
--    end;
    snap = function(info)
        mode = "snap"
        local seconds
        pic_num, seconds = string.match(info, "(.*),(.*)")
        countdown = tonumber(seconds)
        countdown_end = sys.now() + countdown
    end;
    collage = function()
--        pictures = resource.load_image "picture.jpg"
        
--            resource.load_image "picture2.jpg",
--            resource.load_image "picture3.jpg",
--            resource.load_image "picture4.jpg",
--        }
        mode = "collage"
    end;
    loop = function()
        mode = "loop"
    end;
    renner_nr = function(info)
        ren_nr = info
        if string.len(ren_nr) == 3 then
           ren_nr_state = "Renner"
        else 
           ren_nr_state = "Input"
        end
    end;
    
}
local function next_pic(pic_num)
    new_pic_num = new_pic_num +1
    if new_pic_num == 4 then
        new_pic_num = 1
    end 
    return new_pic_num
end

-- Handle loading/unloading of dynamic server response
node.event("content_update", function(filename, file)
    if filename == "dynamic.png" then
        dynamic = resource.load_image(file)
    elseif filename == "picture.jpg" then
        last_pic = next_pic(last_pic)    
        previous_pic[last_pic] = resource.load_image(file)
    end
end)

node.event("content_remove", function(filename)
    if filename == "dynamic.png" and dynamic then
        dynamic:dispose()
        dynamic = nil
    end
end)

function node.render()
    -- part that that we want to display in all modes
    gl.clear(1, 1, 1, 0)
    -- Title 
    t_font:write(50, 50, t_text, 75, 1,1,1,1)
    -- Renner info 
    d_font:write(60, 125, racer_text, 30 ,1,1,1,1)
    d_font:write(150,125, racer_nr, 60 ,1,1,1,1)
    d_font:write(60,200, racer_name, 30 ,1,1,1,1)
    -- Vorige 
    d_font:write(50,300, previous_text, 30 ,1,1,1,1)
    -- draw last picture 
    if previous[last_pic] then
           previous[last_pic]:draw(300, 400, 700, 1000)
    end
    -- draw pic before last picture 
    if previous_pic[next_pic(last_pic)] then
           previous_pic[next_pic(last_pic)]:draw(60, 400, 250, 685)
    end
    if previous_pic[next_pic(next_pic(last_pic))] then
           previous_pic[next_pic(next_pic(last_pic))]:draw(60, 715, 250, 1000)
    end
    -- old info for debuging 
    -- text_renner(HEIGHT-50, ren_nr, 50, 1,1,1,1)
    -- text_renner(HEIGHT-200, ren_nr_state, 50, 1,1,1,1)
    -- countdown during the snap mode 
    if mode == "snap" then
        local remaining = math.max(0, countdown_end - sys.now())

        -- Flash effect
        local flash = math.max(0, 1-remaining*5)
--        gl.clear(1, 1, 1, 0)

        -- Info Text
        local size = math.ceil(HEIGHT/10)
        local mid = HEIGHT/2
        if remaining > 0 then
            -- text_center(mid, string.format("%.2f", remaining), size/2, 1,1,1,1)
        else
            text_center(mid, "Taking Picture", size/2, 0,0,0,1)
        end
        -- Progress Slider
        local progress = WIDTH/2 - WIDTH/2 / countdown * remaining
        black:draw(0, mid-size/2, WIDTH, mid+size/2, 0.1)
        white:draw(0, mid-size/2, progress, mid+size/2, 0.2)
        white:draw(WIDTH, mid-size/2, WIDTH-progress, mid+size/2, 0.2)
        text_renner(HEIGHT, string.format("%d", ren_nr), size, 1,1,1,1)
--    elseif mode == "collage" then
--        local w = WIDTH/2
--        local h = HEIGHT/2
--        for pic_num = 1, 4 do
--        pic_num = 1
--            local x = (pic_num-1)%2 * w
--            local y = math.floor((pic_num-1)/2) * h
--            pictures:draw(x, y)
--        end
--        overlay:draw(0, 0, WIDTH, HEIGHT)
--        if dynamic then
--            dynamic:draw(0, 0, WIDTH, HEIGHT)
--        end
    elseif mode == "wait" then
        text_center(WIDTH/2 - (HEIGHT/10), "Wait - Wait - Wait", HEIGHT/5, 1,1,1,.5)
    end
end
