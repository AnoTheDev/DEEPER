Game = Object:extend()

function Game:new()
   self.state = FSM(self , self.play_state)
   local scenes = {
      ["play"] = Play()
   }
   self.scene_manager = SceneManager(scenes)
   self.scene_manager:load("play")
end

function Game:update(dt)
   self.state:update(dt)
   self.scene_manager:update(dt)
end

function Game:menu_state(dt)
   -- Menu state logic
end

function Game:play_state(dt)

end

function Game:mousepressed(x, y, button)
   self.scene_manager:mousepressed(x , y , button)
end

function Game:keypressed(key)
   self.scene_manager:keypressed(key)
end

function Game:draw()
   self.scene_manager:draw()
end
