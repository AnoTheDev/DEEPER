Game = Object:extend()

function Game:new()
   self.state = FSM(self , self.play_state)
end

function Game:update(dt)
   self.state:update(dt)
end

function Game:menu_state(dt)
   -- Menu state logic
end

function Game:play_state(dt)
   
end

function Game:mousepressed(x, y, button)

end

function Game:keypressed(key)

end

function Game:draw()
   
end
