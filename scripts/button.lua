Button = Object:extend()

function Button:new(x, y, width, height, text, onClick , font)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text
    self.onClick = onClick or function() end
    self.isHovered = false
    self.mouseOver = false
    self.normalColor = Utils.color(255 , 0 , 21 , 255)    -- Default background color
    self.hoverColor = Utils.color(255 , 210 , 0 , 255)   -- Background color when hovered
    self.textColor = Utils.color(0 , 0 , 0 , 255)         -- Text color
    self.font = font or love.graphics.newFont("assets/fonts/gothic.otf", 26) -- Default font
    self.hover_sound = love.audio.newSource("assets/sounds/hover.wav" , "static")
    self.hover_sound:setVolume(0.3)
    self.click_sound = love.audio.newSource("assets/sounds/select.wav" , "static")
    self.click_sound:setVolume(0.3)
    self.sounded = false
end

function Button:setColors(normal, hover, text)
    self.normalColor = normal or self.normalColor
    self.hoverColor = hover or self.hoverColor
    self.textColor = text or self.textColor
end

function Button:setFont(font)
    self.font = font
end

function Button:isMouseOver(mx, my)
    return mx >= self.x and mx <= self.x + self.width and my >= self.y and my <= self.y + self.height
end

function Button:update(dt)
    local mx, my = _G.calculated_mouse_pos.real_x , _G.calculated_mouse_pos.real_y
    self.isHovered = self:isMouseOver(mx, my)
    if self.isHovered == false then
        self.sounded = false
    end

    if self.isHovered == true and self.sounded == false then
        self.hover_sound:stop()
        self.hover_sound:setPitch(Lume.random(0.9 , 1.1))
        self.hover_sound:play()
        self.sounded = true
    end
end

function Button:mousePressed(x, y, button)
    if self.isHovered == false then
        return
    end
    
    if button == 1 and self:isMouseOver(x, y) then
        self:pressed()
    end
end

function Button:pressed()
    self.onClick()
    self.click_sound:stop()
    self.click_sound:play()
end

function Button:draw()
    -- Set button color based on hover state

    -- Draw button background
    local draw_x = self.x
    local draw_y = self.y
    local roundness = 2
    local border_thickness = 4
    love.graphics.setLineStyle("smooth")


    if self.isHovered == true then
        draw_x = self.x + math.cos(love.timer.getTime() * 10) * 2
        draw_y = self.y + math.sin(love.timer.getTime() * 10) * 2
        love.graphics.setColor(Utils.color(255 , 252 , 254 , 255))
    else
        love.graphics.setColor(Utils.color(17 , 7 , 10 , 255))
    end
    love.graphics.rectangle("fill", draw_x - border_thickness, draw_y - border_thickness, self.width + border_thickness * 2, self.height + border_thickness * 2 , roundness , roundness)

    if self.isHovered then
        love.graphics.setColor(self.hoverColor)
    else
        love.graphics.setColor(self.normalColor)
    end

    love.graphics.rectangle("fill", draw_x, draw_y, self.width, self.height ,  roundness , roundness)

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()
    love.graphics.print(self.text, draw_x + (self.width - textWidth) / 2, draw_y + (self.height - textHeight) / 2)
    love.graphics.setColor(Utils.color(1 , 1 , 1, 1))
end

