Depth = Object:extend()

function Depth:new(x , y)
    self.x = x or 16
    self.y = y or 32
    self.target_value = 0
    self.value = 0
    self.scale = 1
    self.tick_timer = Timer()
    self.font = love.graphics.newFont("assets/fonts/RubikMonoOne-Regular.ttf" , 24)
end

function Depth:update(dt)
    self.tick_timer:update(dt)
    if self.value ~= self.target_value then
        self.tick_timer:start(0.1 , function ()
            self.value = self.value + math.ceil((self.target_value - self.value)/1.7)
            self.value = Utils.move_to(self.value , self.target_value , 1)
            self.scale = Utils.move_to(self.scale , 1.5 , dt * 3)
        end)
    else
        self.scale = Utils.lerp(self.scale , 1 , dt * 10)
    end
end

function Depth:update_Depth(new_Depth)
    self.target_value = new_Depth
end

function Depth:draw()
    love.graphics.setFont(self.font)
    local text_width = self.font:getWidth(self.value.."M")
    local text_height = self.font:getHeight()
    love.graphics.print(self.value , 0, 0)
    love.graphics.print(self.value.."M" , self.x - (8 + self.font:getWidth(self.value.."M")) , self.y - (8 + self.font:getHeight(self.font)) , 0 , self.scale , self.scale)
end