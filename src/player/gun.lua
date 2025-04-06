Gun = Object:extend()

function Gun:new(parent)
    self.parent = parent
    self.offset = {x = 21, y = 12}  -- Relative offset from the player
    self.angle, self.recoil_angle = 0, 0

    self.recoil_timer = Timer()
    self.sprite = Sprite({
        image = "assets/images/player/gun/gun.png",
        origin = {-6, 7},
        center_origin = true,
    })
    self.brain = FSM(self, self.normal_shot)

    self.gun_base = {x = 0, y = 0}
    self.muzzle_length = 25

    self.shot_timer = Timer()
    self.shot_delay = 0.18

    self.charging = false
    self.charge_amount = 0
    self.charge_max = 5

    -- self.sounds = {
    --     charge = love.audio.newSource("assets/sounds/charge.wav", "static"),
    --     reject = love.audio.newSource("assets/sounds/reject.wav", "static")
    -- }
    -- self.sounds.charge:setLooping(true)
    self.spin_amount = 0
    self.max_spin = 30

    self:register_events()
end

function Gun:register_events()
    -- Event.on("add_spin_amount" , function (amount)
    --     self.spin_amount = math.min(self.spin_amount + amount , self.max_spin)
    --     Event.dispatch("set_spin_amount" , self.spin_amount)
    -- end)
end

function Gun:update(dt)
    self:update_offset()
    self:update_aim()
    self.brain:update(dt)
    self.shot_timer:update(dt)
    self.recoil_timer:update(dt)
end

function Gun:update_aim()
    local mouse_x = Pushed_Mouse.cam_x
    local mouse_y = Pushed_Mouse.cam_y
    local base_x = self.parent.x + self.offset.x + self.sprite.origin[1] 
    local base_y = self.parent.y + self.offset.y + self.sprite.origin[2]

    -- Calculate angle towards the mouse
    self.angle = math.atan2(mouse_y - base_y, mouse_x - base_x)

    -- Update gun base position
    self.gun_base.x = base_x + math.cos(self.angle) * self.muzzle_length
    self.gun_base.y = base_y - 3 + math.sin(self.angle) * self.muzzle_length
end

function Gun:normal_shot()
    if love.mouse.isDown(1) then
        self:shoot()
    end
end

function Gun:shoot()
    if self.shot_timer.active then return end

    -- Create a bullet
    -- local bullet = Bullet(self.gun_base.x, self.gun_base.y, self.angle, 30)

    -- Apply recoil
    local recoil_range = math.rad(Lume.random(15, 60))
    self.recoil_angle = self.sprite.flip_y and recoil_range or -recoil_range
    self.recoil_timer:start(0.1, function() self.recoil_angle = 0 end)

    -- Start shot timer
    self.shot_timer:start(self.shot_delay)

    Event.dispatch("spin_engine", 20)
    Event.dispatch("shot" , 1.5 , 10)
    -- Event.dispatch("add_bullet" , bullet)
end

function Gun:mousepressed(x , y , button)

end

function Gun:update_offset()
    if self.offset.x ~= self.sprite.offset[1] or self.offset.y ~= self.sprite.offset[2] then
        self.sprite.offset = {self.offset.x, self.offset.y}
    end
end

function Gun:draw()
    local final_angle = self.angle + self.recoil_angle
    self.sprite:draw(self.parent.x, self.parent.y, final_angle)
end
