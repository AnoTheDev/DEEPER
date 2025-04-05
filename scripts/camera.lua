Camera = Object:extend()

function Camera:new(zoom, target, follow_speed)
    self.zoom = zoom
    self.target_zoom = zoom
    self.zoom_calm_speed = 5
    self.target = target or nil
    self.follow_speed = follow_speed or 2
    self.x = 0
    self.y = 0
    self.shaking = false

    if self.target then
        self.x = target.x - (WORLD_SIZE.WIDTH / 2) / self.zoom
        self.y = target.y - (WORLD_SIZE.HEIGHT / 2) / self.zoom
    end

    self.offset = {x = 0, y = 0}
    self.shake_pow = 0
    self.shake_calm_speed = 5
end

function Camera:update(dt)
    self:follow(dt)
    self.offset.x = Lume.random(-self.shake_pow, self.shake_pow)
    self.offset.y = Lume.random(-self.shake_pow, self.shake_pow)
    self.shake_pow = Utils.lerp(self.shake_pow, 0, dt * self.shake_calm_speed)
    self.zoom = Utils.lerp(self.zoom, self.target_zoom, dt * self.zoom_calm_speed)
    -- self.zoom = Utils.lerp(self.zoom, self.target_zoom, dt * self.zoom_calm_speed)

    if self.shake_pow >= 5 then
        self.shaking = true
    else
        self.shaking = false
    end
end

function Camera:lock_on(dt)
    local target_x = self.target.x - (WORLD_SIZE.WIDTH / 2) / self.zoom
    local target_y = self.target.y - (WORLD_SIZE.HEIGHT / 2) / self.zoom
    
    self.y = target_y
    self.x = target_x
end

function Camera:shake(amount, speed)
    self.shake_pow = amount or 500
    self.shake_calm_speed = speed or 2
end

function Camera:zoom_in(amount, speed)
    self.target_zoom = amount or 1
    self.zoom_calm_speed = speed or 2
end

function Camera:follow(dt)
    if not self.target then return end

    local target_x = self.target.x - (WORLD_SIZE.WIDTH / 2) / self.zoom + self.offset.x
    local target_y = self.target.y - (WORLD_SIZE.HEIGHT / 2) / self.zoom + self.offset.y

    if self.shaking == false then
        self.y = Utils.lerp(self.y, target_y, dt * self.follow_speed * self.zoom)
        self.x = Utils.lerp(self.x, target_x, dt * self.follow_speed * self.zoom)
    else
        self.y = target_y
        self.x = target_x
    end
end