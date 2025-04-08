Dummy = Enemy:extend()

local super = Dummy.super

function Dummy:new(x , y)
    self.brain = FSM(self)
    self.animator = Animation(self)
    self.animator.scale = {1.3 , 1.3}
    self.animator:add("assets/images/enemies/dummy", "dummy", {12, 24}, true)
    self.animator:play("dummy", true, 0.2)
    
    super.new(self , self , x , y , self.brain , self.animator , 5 , 32 ,  {})
end

function Dummy:update(dt)
    super.update(self , dt)
end

function Dummy:draw()
    super.draw(self)
    self.animator:draw()
end