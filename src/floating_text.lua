Float_Text = Object:extend()

function Float_Text:new(x , y , text)
    self.x = x or 16
    self.y = y or 32
    self.text = tostring(text) or "ass"
    self.opacity = 1.0
    self.scale = 1
    self.tick_timer = Timer()
    self.font = love.graphics.newFont("assets/fonts/jetbrains.ttf" , 64)
end

function Float_Text:update(dt)
    self.y = self.y - dt * 100
    self.opacity = Utils.lerp(self.opacity , 0 , dt * 1)
    self.scale = self.scale + 0.05 * dt
end

function Float_Text:draw()
    local text_width = self.font:getWidth(self.text)
    local text_height = self.font:getHeight()
    love.graphics.setColor(1 , 1 , 1 , self.opacity)
    love.graphics.print(self.text , self.x + text_width/2 , self.y + text_height/2 , 0 , self.scale , self.scale , text_width/2 , text_height/2)
end