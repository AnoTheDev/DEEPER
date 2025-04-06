Play = Object:extend()

function Play:register_events()
    Event.on("add_bullet", function(bullet)
        table.insert(self.bullets, bullet)
        table.insert(self.sortable_objects, bullet)
    end)

    Event.on("cam_shake" , function (amount , speed)
        self.camera:shake(amount , speed)
    end)

    Event.on("remove_bullet", function(bullet)
        Utils.remove_from_list(self.sortable_objects, bullet)
        Utils.remove_from_list(self.bullets, bullet)
    end)

    Event.on("remove_enemy", function(enemy)
        Event.dispatch("remove_hitbox" , enemy.hitbox)
        Utils.remove_from_list(self.sortable_objects , enemy)
        Utils.remove_from_list(self.enemies, enemy)
    end)

    Event.on("add_enemy", function(enemy)
        table.insert(self.enemies , enemy)
        table.insert(self.sortable_objects , enemy)
    end)

    Event.on("add_hitbox", function(box)
        if box:is(Hitbox) == false then
            error("none hitbox passed to the hitbox table")
        end
        table.insert(self.hitboxes , box)
    end)

    Event.on("add_hurtbox", function(box)
        if box:is(Hurtbox) == false then
            error("none hurtbox passed to the hitbox table")
        end
        table.insert(self.hurtboxes , box)
    end)

    Event.on("remove_hitbox", function(box)
        Utils.remove_from_list(self.hitboxes , box)
    end)

    Event.on("remove_hurtbox", function(box)
        Utils.remove_from_list(self.hurtboxes , box)
    end)
end

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

    self.bullets = {}
    self.enemies = {}
    self.hitboxes = {}
    self.hurtboxes = {}
    self.sortable_objects = {self.player}
    
    self:register_events()
    Event.dispatch("retrieve_boxes")
    Event.dispatch("add_enemy" , Dummy(24 , 24))
    Event.dispatch("add_enemy" , Dummy(472 - 64 , 24))
    Event.dispatch("add_enemy" , Dummy(236 , 180))
end

function Play:load()
    
end

function Play:update(dt)
    self.smoke:update(dt)
    self.state:update(dt)
    self:handle_camera(dt , 0.05 , 0.8)
    self:handle_collisions()
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

    for index, enemy in ipairs(self.enemies) do
        enemy:update(dt)
    end

    for index, bullet in ipairs(self.bullets) do
        bullet:update(dt)
    end
end

function Play:handle_collisions()
    for i, hitbox in ipairs(self.hitboxes) do
        for j, hurtbox in ipairs(self.hurtboxes) do
            -- if hitbox.parent:is(Player) and hurtbox.parent:is(Enemy_Bullet) then
            --     hurtbox:overlaped(hitbox)
            -- end
            if hitbox.parent:is(Enemy) and (hurtbox.parent:is(Bullet) or hurtbox.parent:is(Bullet)) then
                hurtbox:overlaped(hitbox)
            end
        end    
    end
end

function Play:pause(dt)
    
end

function Play:mousepressed(x , y , button)
    self.player:keypressed(x , y , button)
end

function Play:keypressed(key)
    self.player:keypressed(key)

    if key == "/" then
        DEBUGGING = not DEBUGGING
        
        for index, value in ipairs(self.hitboxes) do
           value.debug = DEBUGGING 
        end

        for index, value in ipairs(self.hurtboxes) do
            value.debug = DEBUGGING
        end
    end
end

function Play:close()

end

function Play:draw_fight()
    table.sort(self.sortable_objects , function (a , b)
        return not(a.y + a.height > b.y + b.height)
    end)

    self.floor:draw(0 , 0)

    for index, Object in ipairs(self.sortable_objects) do
        Object:draw()
    end
end

function Play:draw()
    love.graphics.push()
        love.graphics.scale(self.camera.zoom)
        love.graphics.translate(-self.camera.x, -self.camera.y)
        love.graphics.rotate(self.tilt)
        self:draw_fight()
        love.graphics.draw(self.smoke, 236, 180)
    love.graphics.pop()
end
