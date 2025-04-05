Block = Object:extend()

function Block:new(pos , color)
    self.block_image = love.graphics.newImage("assets/images/blocks/"..color..".png")
    self.grid_position = pos or {x = 0 , y = 0}
    self.offset = {x = 0 , y = 0}
    self.size = 16
    self.scale = 3
end

function Block:draw(x , y , scale)
    local new_x = x or self.grid_position.x
    local new_y = y or self.grid_position.y
    local size = scale or self.scale
    love.graphics.draw(self.block_image , new_x , new_y , 0 , scale , scale)
end

