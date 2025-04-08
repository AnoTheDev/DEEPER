Pickaxe = Enemy:extend()

local super = Pickaxe.super

function Pickaxe:new(x , y)
    self.brain = FSM(self)
    self.animator = Animation(self)
    -- self.animator.scale = {1.3 , 1.3}
    self.animator:add("assets/images/enemies/pickaxe/run-down", "run-down", {12, 24}, true)
    self.animator:add("assets/images/enemies/pickaxe/run-up", "run-up", {12, 24}, true)
    self.animator:play("run-down", true, 0.2)
    
    super.new(self , self , x , y , self.brain , self.animator , 5 , 32 ,  {})
end

function Pickaxe:update(dt)
    super.update(self , dt)
end

function Pickaxe:draw()
    super.draw(self)
    self.animator:draw()
end