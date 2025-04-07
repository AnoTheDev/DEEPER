Upgrade = Object:extend()

function Upgrade:new(x , y)
    self.x = x or 0
    self.y = y or 0
    self.rot = 0
    self.scale = 1
    self.width = 111
    self.height = 177
    self.buff = nil
    self.buff_des = ""
    self.font = love.graphics.newFont("assets/fonts/RubikMonoOne-Regular.ttf" , 10)
end

function Upgrade:change_buff(buff , amount , des , call)
    self.buff_des = des.. ": ".. amount
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
    -- if self.isHovered == false then
    --     self.sounded = false
    -- end

    -- if self.isHovered == true and self.sounded == false then
    --     self.hover_sound:stop()
    --     self.hover_sound:setPitch(Lume.random(0.9 , 1.1))
    --     self.hover_sound:play()
    --     self.sounded = true
    -- end
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
    end
end

function Upgrade:draw()
    love.graphics.setFont(self.font)
    if self.isHovered then
        love.graphics.setColor(Utils.color("ed1515"))
    else
        love.graphics.setColor(Utils.color("5614ba"))
    end
    love.graphics.rectangle("fill" , self.x , self.y , 111 * self.scale, 177 * self.scale)
    love.graphics.print(self.buff_des , self.x - self.font:getWidth(self.buff_des)/2 + 64 , self.y - 32)
    -- love.graphics.setColor(Utils.color("11070a"))
    -- love.graphics.rectangle("fill" , self.x , self.y , 109 , 175)
    love.graphics.setColor(Utils.color())
end