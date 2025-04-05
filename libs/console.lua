Console = Object:extend()

function Console:new(settings)
    self.x = settings.x or 0
    self.y = settings.y or 0
    self.bind = settings.bind or "7"
    self.debug_size = settings.size or 5
    self.active = true
    self.debugs = {}
    self.default_font = love.graphics.newFont()
end

function Console:print(output)
    if self.active == true then
        if #self.debugs > 0 then
            if #self.debugs >= self.debug_size then
                table.remove(self.debugs , 1)
            end
        end
        table.insert(self.debugs, output)
    end
end

function Console:clear()
    for index, _ in ipairs(self.debugs) do
        self.debugs[index] = nil
    end
end


function Console:keypressed(key)
    if key == self.bind then
        self.active = not self.active
    end
end

function Console:toggle_pause(on_off)
    self.active = on_off
end

function Console:draw()
    love.graphics.setFont(self.default_font)
    -- self.active == true and 
    if #self.debugs > 0 then
        for i, v in ipairs(self.debugs) do
            local text = i .. " : " .. tostring(v)
            love.graphics.print(text , self.x , self.y + (15 * i))
        end
    end
end
