Upgrade = Object:extend()

function Upgrade:new(x , y)
    self.x = x or 0
    self.y = y or 0
    self.rot = 0
    self.scale = 1
    self.width = 111
    self.height = 177
    self.buff = nil
    self.click_sound = love.audio.newSource("assets/sounds/buff.wav" , "static")
    self.buff_des = ""
    self.rarity = "common"
    self.font = love.graphics.newFont("assets/fonts/RubikMonoOne-Regular.ttf" , 10)
end

function Upgrade:change_buff(buff , amount , des , rarity , call)
    self.buff_des = des.. ": ".. amount
    self.rarity = rarity
    self.buff = function ()
        Event.dispatch(buff , amount)
        if call then
            call()
        end
    end
end

function Upgrade:update(dt)
    local mx, my = Pushed_Mouse.real_x , Pushed_Mouse.real_y
    self.isHovered = self:isMouseOver(mx, my)
end

function Upgrade:isMouseOver(mx, my)
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

function Upgrade:mousepressed(x, y, button)
    if self.isHovered == false then
        return
    end
    
    if button == 1 and self:isMouseOver(Pushed_Mouse.real_x, Pushed_Mouse.real_y) then
        self.buff()
        Event.dispatch("new_wave")
        self.click_sound:play()
    end
end

function Upgrade:draw()
    love.graphics.setFont(self.font)
    if self.isHovered then
        love.graphics.setColor(Utils.color("edfcff"))
    else
        if self.rarity == "common" then
            love.graphics.setColor(Utils.color("7ab012"))
        elseif self.rarity == "rare" then
            love.graphics.setColor(Utils.color("5614ba"))
        elseif self.rarity == "dive" then
            love.graphics.setColor(Utils.color("f05203"))
        end
    end
    love.graphics.rectangle("fill" , self.x , self.y , 111 * self.scale, 177 * self.scale)
    love.graphics.print(self.buff_des , self.x - self.font:getWidth(self.buff_des)/2 + 64 , self.y - 32)
    love.graphics.print(self.rarity , self.x - self.font:getWidth(self.rarity)/2 + 56 , self.y + 182)
    -- love.graphics.setColor(Utils.color("11070a"))
    -- love.graphics.rectangle("fill" , self.x , self.y , 109 , 175)
    love.graphics.setColor(Utils.color())
end