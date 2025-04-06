Play = Object:extend()

function Play:new()
    self.state = FSM(self , self.play)
    self.player = Player(0 , 0)
    self.camera = Camera(1 , self.player , 5)
    self.tilt = 0

    local smoke_image = love.graphics.newImage("assets/images/smoke.png")
    self.smoke = love.graphics.newParticleSystem(smoke_image, 1000)
    self.smoke:setParticleLifetime(1, 3)      -- Each smoke particle lives between 2 and 5 seconds
    self.smoke:setEmissionRate(150)
    self.smoke:setSizeVariation(0)
    -- self.smoke:setLinearAcceleration(-5, -5, 5, 5)  -- Random slight drift
    self.smoke:setEmissionArea("borderrectangle", 472/2 + 16, 360/2 + 16)
    -- self.smoke:setAreaSpread("uniform", 10, 10)  -- Spread across the arena
    self.smoke:setColors(150, 150, 150, 150, 150, 150, 150, 100) -- Fade out over time
    self.smoke:setColors(100, 100, 100, 100, 100, 100, 100, 100)
    self.smoke:setSizes(1.0, 2 , 1.5)
    self.smoke:setSpin(-2, 2) 
    
    self.floor = Sprite({
        image = "assets/images/floors/"..tostring(Lume.randomchoice(love.filesystem.getDirectoryItems("assets/images/floors"))),
        origin = {0, 0},
        center_origin = false,
    })
end

function Play:load()
    
end

function Play:update(dt)
    self.smoke:update(dt)
    self.state:update(dt)
    self:handle_camera(dt , 0.05 , 0.8)
    self:mousecontrol()
end

function Play:get_tilt_target(tilt_amount)
    if self.player.velocity.x > 0 then
        return tilt_amount
    elseif self.player.velocity.x < 0 then
        return -tilt_amount
    else
        return 0
    end
end

function Play:handle_camera(dt, tilt_amount, tilt_speed)
    self.tilt = Utils.lerp(self.tilt, self:get_tilt_target(tilt_amount), dt * tilt_speed)
end

function Play:mousecontrol()
    local x , y = love.mouse.getPosition()
    local game_x, game_y = Push:toGame(x, y)

    local zoom = self.camera.zoom
    local cam_x, cam_y = self.camera.x, self.camera.y
    Pushed_Mouse.cam_x = (game_x + cam_x * zoom) / zoom
    Pushed_Mouse.cam_y = (game_y + cam_y * zoom) / zoom
end

function Play:play(dt)
    self.camera:update(dt)
    self.player:update(dt)
end

function Play:pause(dt)
    
end

function Play:mousepressed(x , y , button)
    self.player:keypressed(x , y , button)
end

function Play:keypressed(key)
    self.player:keypressed(key)
end

function Play:close()

end

function Play:draw()
    love.graphics.push()
        love.graphics.scale(self.camera.zoom)
        love.graphics.translate(-self.camera.x, -self.camera.y)
        love.graphics.rotate(self.tilt)
        self.floor:draw(0 , 0)
        self.player:draw()
        love.graphics.draw(self.smoke, 236, 180)
    love.graphics.pop()
end
