Dummy = Enemy:extend()

local super = Dummy.super

function Dummy:new(x , y)
    self.sprite = Sprite({
        image = "assets/images/enemies/dummy.png",
        origin = {12, 24},
        center_origin = true,
    })
    self.sprite.scale = {1.5 , 1.5}
    self.brain = FSM(self)
    self.animator = Animation(self)
    
    super.new(self , self , x , y , self.brain , self.animator , 50 , 32 ,  {})
end

function Dummy:update(dt)
    super.update(self , dt)
end

function Dummy:take_damage()
    Log("OW")
end

function Dummy:draw()
    self.sprite:draw(self.x , self.y)
    super.draw(self)
end