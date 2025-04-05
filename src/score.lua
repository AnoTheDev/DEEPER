Score = Object:extend()

function Score:new(x , y)
    self.x = x or 16
    self.y = y or 32
    self.target_value = 0
    self.value = 0
    self.scale = 1
    self.tick_timer = Timer()
    self.font = love.graphics.newFont("assets/fonts/jetbrains.ttf" , 64)
end

function Score:update(dt)
    self.tick_timer:update(dt)
    if self.value ~= self.target_value then
        self.tick_timer:start(0.05 , function ()
            self.value = self.value + math.ceil((self.target_value - self.value)/1.7)
            self.value = Utils.move_to(self.value , self.target_value , 1)
            self.scale = Utils.move_to(self.scale , 1.5 , dt * 3)
        end)
    else
        self.scale = Utils.lerp(self.scale , 1 , dt * 10)
    end
end

function Score:update_score(new_score)
    self.target_value = new_score
end

function Score:draw()
    local text_width = self.font:getWidth(self.value)
    local text_height = self.font:getHeight()
    love.graphics.print(self.value , self.x + text_width/2 , self.y + text_height/2 , 0 , self.scale , self.scale , text_width/2 , text_height/2)
end