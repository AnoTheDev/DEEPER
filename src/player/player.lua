require "src.player.globals"
require "src.player.gun"


Player = Object:extend()

function Player:new(x , y)
    self.x = x or 160
    self.y = y or 90
    self.height = 24
    self.velocity = {x = 100, y = 0}
    self.movement_direction = {x = 1, y = 1}
    self.direction = "down"
    MOVE_SPEED = 170
    self.limits = {left = 0, right = 472 - 24, top = 0, bottom = 360-24}
    self.brain = FSM(self, self.movement)
    self.animator = Animation(self)
    self.animator:add("assets/images/player/run-down", "run-down", {12, 24}, true)
    self.animator:add("assets/images/player/run-up", "run-up", {12, 24}, true)
    self.animator:add("assets/images/player/idle-down", "idle-down", {12, 24}, true)
    self.animator:add("assets/images/player/idle-up", "idle-up", {12, 24}, true)
    self.animator:play("idle-down", true, 0.2)
    self.anim_rot = 0
    self.gun = Gun(self)
end

function Player:update(dt)
    self.gun:update(dt)
    self.brain:update(dt)
    self.animator:update(dt)
    self.animator.rot = self.anim_rot
    self:mouse_control(dt)
end

function Player:set_limits()
    -- Constrain player position within limits
    self.x = math.max(self.limits.left, math.min(self.x, self.limits.right))
    self.y = math.max(self.limits.top, math.min(self.y, self.limits.bottom))
end

function Player:movement(dt)
    self.velocity = {x = 0, y = 0}
    self.movement_direction = {x = 0, y = 0}
    self.anim_rot = 0

    if love.keyboard.isDown("a") then
        self.velocity.x, self.anim_rot, self.movement_direction.x = -MOVE_SPEED, math.rad(-6), -1
    elseif love.keyboard.isDown("d") then
        self.velocity.x, self.anim_rot, self.movement_direction.x = MOVE_SPEED, math.rad(6), 1
    end

    if love.keyboard.isDown("w") then
        self.velocity.y, self.movement_direction.y = -MOVE_SPEED, -1
    elseif love.keyboard.isDown("s") then
        self.velocity.y, self.movement_direction.y = MOVE_SPEED, 1
    end

    -- Normalize velocity
    local length = math.sqrt(self.velocity.x^2 + self.velocity.y^2)
    if length > 0 then
        self.velocity.x = (self.velocity.x / length) * MOVE_SPEED
        self.velocity.y = (self.velocity.y / length) * MOVE_SPEED
    end

    -- Update position and check limits
    self.x = self.x + self.velocity.x * dt
    self.y = self.y + self.velocity.y * dt
    self:set_limits()

    -- Switch animation state based on movement
    local state = (self.velocity.x == 0 and self.velocity.y == 0) and "idle" or "run"
    self.animator:play(state .. "-" .. self.direction, true, (self.velocity.x == 0 and self.velocity.y == 0) and 0.5 or 0.1)
end

function Player:mouse_control(dt)
    local mouse_x, mouse_y = Pushed_Mouse.cam_x, Pushed_Mouse.cam_y

    -- Adjust flip_x and aim_direction based on mouse position
    self.animator.flip_x = mouse_x < self.x + 12
    self.gun.sprite.flip_y = self.animator.flip_x
    -- self.aim_direction = self.animator.flip_x and "left" or "right"

    -- Set movement direction based on mouse position
    self.direction = mouse_y < self.y and "up" or "down"
end

function Player:keypressed(key)
    
end

function Player:mousepressed(x , y , button)
    self.gun:mousepressed(x , y , button)
end

function Player:draw()
    if self.gun.gun_base.y < self.y + 12 then
        self.gun:draw()
    end

    self.animator:draw()

    if self.gun.gun_base.y > self.y + 12 then
        self.gun:draw()
    end
    -- love.graphics.rectangle("fill" , self.x , self.y , 32 , 32)
end