local sprite_sheet_manager = {} -- This sprite sheet manager basically will hold all sprite_sheets for player animations or such.

sprite_sheet_manager.sprite_sheets = {}

function sprite_sheet_manager:add(name, quad_w, quad_h, num_quads, animation_length, sprite_sheet_file_path)
    local image = love.graphics.newImage(sprite_sheet_file_path);
    local quads = {}
    local count = 1; -- quad count starts with 1, the basic lua way.
    for row=0, math.floor(image:getHeight()/quad_h)-1 do
        for column=0, math.floor(image:getWidth()/quad_w)-1 do
            quads[count] = love.graphics.newQuad(column*quad_w, row*quad_h,quad_w, quad_h, image:getWidth(), image:getHeight());
            count = count + 1;
            if count > num_quads then
                break;
            end
        end
        if count > num_quads then
            break;
        end
    end

    self.sprite_sheets[name] = {quads=quads, num_quads = num_quads, cur_time = 0, animation_length=animation_length, paused= false, img=image} -- It will be referenced by name (ex : player for player's)
end

function sprite_sheet_manager:pause(name)
    self.sprite_sheets[name].paused = true;
end

function sprite_sheet_manager:unpause(name)
    self.sprite_sheets[name].paused = false;
end

function sprite_sheet_manager:toggle_pause(name) -- is paused, becomes unpaused, and if unpaused becomes paused
    self.sprite_sheets[name].paused = not self.sprite_sheets[name].paused
end

function sprite_sheet_manager:update(dt)
    for k,v in pairs(self.sprite_sheets) do
        if not v.paused then
            v.cur_time = (v.cur_time + dt)%v.animation_length; -- The sprite to draw is determined at the time of drawing
            -- because love.draw happens way less often compared to love.update
        end
    end
end

function sprite_sheet_manager:draw(name, x, y)
    local m = self.sprite_sheets[name]
    love.graphics.draw(m.img, m.quads[math.ceil(m.num_quads * (m.cur_time)/(m.animation_length))], x, y);
end

return sprite_sheet_manager -- this could be shortened to ssmanager in main.lua