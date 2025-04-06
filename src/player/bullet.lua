Bullet = Object:extend()

function Bullet:new(x , y , direction , speed , life_max)
    self.x = x
    self.y = y
    self.angle = --[[ math.rad(direction) ]]direction
    self.speed = speed
    self.velocity = ({x = math.cos(self.angle) * self.speed , y = math.sin(self.angle) * self.speed})
    self.direction = direction
    self.sprite = Sprite({image = "assets/images/bullets/bullet1.png" , origin = {8 ,8} , center_origin = true , offset = {-8 , -8}})
    self.sprite.scale = {1.2 , 1.2}
    self.height = 16
    -- self.shot_sound = love.audio.newSource("assets/sounds/shot.wav", "static")
    -- self.shot_sound:setVolume(0.5)
    -- self.shot_sound:setPitch(Lume.random(0.75 , 1))
    -- self.shot_sound:play()
    self.life = 0
    self.life_max = BULLET_LIFE
    self.hurtbox = Hurtbox(self , self.x , self.y , 16 , 12 , function ()
            Event.dispatch("remove_bullet" , self)
        end , -6 , -5 , 5)    
end

function Bullet:update(dt)
        self.x = self.x + self.velocity.x * (dt * self.speed)
        self.y = self.y + self.velocity.y * (dt * self.speed)
        self.life = self.life + 1 * dt

        if self.life > self.life_max then
            Event.dispatch("remove_bullet" , self)
        end

        if self.x < -32 or self.x > 512 or self.y < -32 or self.y > 360 then
            Event.dispatch("remove_bullet" , self)
        end
        self.hurtbox:update(dt)
end

function Bullet:remove(bullets_table , hurtbox_table)
    -- Event.dispatch("add_effect" , Hit_Spark(self.x , self.y , self.angle , 6))
    Utils.remove_from_list(hurtbox_table , self.hurtbox)
    Utils.remove_from_list(bullets_table , self)
end

function Bullet:draw()
    love.graphics.circle("line" , self.x , self.y , 5)
    self.sprite:draw(self.x , self.y , self.direction)
    self.hurtbox:draw()
end