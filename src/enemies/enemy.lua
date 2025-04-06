Enemy = Object:extend()

function Enemy:new(child , x , y , fsm , animator , health , height ,  box_values)
    self.x = x or 320 
    self.y = y or 256
    self.target_location = {x = Lume.random(0, 472 - 32) , y = Lume.random(0, 360 - 32)}
    self.brain = fsm
    self.brain:change_state(self.idle)
    self.height = height or 32
    self.attack_timer = Timer()
    self.attack_delay = 10

    self.player_data = {}
    
    self.max_health = health
    local box_width = box_values.width or 24
    local box_height = box_values.height or 24
    local box_offset_x = box_values.offset_x or 0 
    local box_offset_y = box_values.offset_y or 0
    self.hitbox = Hitbox(child , self.x , self.y , box_width , box_height , box_offset_x , box_offset_y , self.take_damage , self.max_health)
    self.direction = {x = "right" , y = "down"}
    self.animator = animator or nil

    Event.dispatch("get_player" , self)

    self.flash_timer = Timer()

    self.animator:play("idle-down")
end

function Enemy:limits()
    if self.x < 0 then
        self.x = 0
    end
    
    if self.y + 32 < 0 then
        self.y = 32
    end

    if self.y + 64 > 512 then
        self.y = 512 - 64
    end
end

function Enemy:update(dt)
    self.brain:update(dt)
    self.hitbox:update(dt)
    if self.attack_phase == 1 then
        if self.hitbox.health <= self.health_thres then
            Event.dispatch("change_phase" , 2)
        end
    end 

    if self.hitbox.health <= 0 then
        Event.dispatch("remove_enemy" , self)
    end
end

function Enemy:idle(dt)
    -- self.animator:play("idle-"..self.direction.y , true , 0.3)
    self.attack_timer:update(dt)
    self.x = Utils.lerp(self.x , self.target_location.x , dt * 10)
    self.y = Utils.lerp(self.y , self.target_location.y , dt * 10)
    self.attack_timer:start(self.attack_delay , function ()
        self.target_location.x = Lume.random(0 , 472 - 64)
        self.target_location.y = Lume.random(0 , 360 - 64)
    end)
    local direction = self.direction.x == "right" and 1 or -1
    self.animator.scale[1] = Utils.lerp(self.animator.scale[1] , 2 , dt * 20)
    self.animator.scale[2] = Utils.lerp(self.animator.scale[2] , 2 , dt * 20)
end

function Enemy:take_damage(damage_amount)
    if self.animator then
        self.animator:flash(3)
        self.animator:shake(5 , 0.2)
    end
end

function Enemy:draw()
    self.hitbox:draw()
end