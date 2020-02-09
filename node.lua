gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.no_globals()

local white = resource.create_colored_texture(1,1,1,1)
local black = resource.create_colored_texture(0,0,0,1)
local t_font = resource.load_font "font.ttf"
local d_font = resource.load_font "font.ttf"
local t_text = " "
local racer_text =" "
local previous_text = " "
local racer_nr = " "
local racer_name = " "

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
    racer_text = config.reacer_text
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
        pictures = resource.load_image "picture1.jpg"
        
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

-- Handle loading/unloading of dynamic server response
node.event("content_update", function(filename, file)
    if filename == "dynamic.png" then
        dynamic = resource.load_image(file)
    elseif filiname == "picture1.jpg" then    
        previous_pic1 = resource.load_image(file)
    elseif filiname == "picture2.jpg" then    
        previous_pic2 = resource.load_image(file)
    elseif filiname == "picture3.jpg" then    
        previous_pic3 = resource.load_image(file)
    end
end)

node.event("content_remove", function(filename)
    if filename == "dynamic.png" and dynamic then
        dynamic:dispose()
        dynamic = nil
    elseif filename == "picture1.jpg" and previous_pic1 then            
        previous_pic1:dispose()
        previous_pic1 = nil
    elseif filename == "picture2.jpg" and previous_pic2 then            
        previous_pic2:dispose()
        previous_pic2 = nil
    elseif filename == "picture3.jpg" and previous_pic3 then            
        previous_pic3:dispose()
        previous_pic3 = nil
    end
end)

function node.render()
    -- part that that we want to display in all modes
    -- Title 
    t_font:write(10, 10, t_text, 50, 1,1,1,1)
    -- Renner info 
    d_font:write(20, 70, racer_text, 30 ,1,1,1,1)
    d_font:write(220,70, racer_nr, 60 ,1,1,1,1)
    d_font:write(20,130, racer_name, 30 ,1,1,1,1)
    -- Vorige 
    d_font:write(20,130, previous_text, 30 ,1,1,1,1)
    if previous_pic1 then
           previous_pic1:draw(20, 200, 200, 300)
    end
    if previous_pic2 then
           previous_pic2:draw(240, 200, 200, 300)
    end
    if previous_pic3 then
           previous_pic3:draw(480, 200, 200, 300)
    end
    -- old info for debuging 
    text_renner(HEIGHT-50, ren_nr, size, 1,1,1,1)
    text_renner(HEIGHT-200, ren_nr_state, size, 1,1,1,1)
    -- countdown during the snap mode 
    if mode == "snap" then
        local remaining = math.max(0, countdown_end - sys.now())

        -- Flash effect
        local flash = math.max(0, 1-remaining*5)
        gl.clear(1, 1, 1, 0)

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
        text_center(WIDTH/2 - (HEIGHT/10), "Wait - Wait - Wait", HEIGHT/10, 1,1,1,.5)
    end
end
