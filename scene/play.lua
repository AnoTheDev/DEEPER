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
        Event.dispatch("remove_hurtbox" , bullet.hurtbox)
        Utils.remove_from_list(self.bullets, bullet)
    end)

    Event.on("remove_enemy", function(enemy)
        Event.dispatch("remove_hitbox" , enemy.hitbox)
        Utils.remove_from_list(self.sortable_objects , enemy)
        Utils.remove_from_list(self.enemies, enemy)
        if #self.enemies <= 0 then
            self.state:change_state(self.ending_wave)
        end
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

    Event.on("new_wave" , function ()
        self.floor_index = Utils.wrap(self.floor_index + 1 , 1 , 7)
        self.player.x = 900
        self.camera:lock_on()
        DEPTH = DEPTH + 200
        self.depth_text:update_Depth(DEPTH)
        self:create_wave()
        self.floor = Sprite({
            image = self.floor_images[self.floor_index],
            origin = {0, 0},
            center_origin = false,
        })
        
        for _, bullet in ipairs(self.bullets) do
            Event.dispatch("remove_bullet" , bullet)
        end
        
        local upgrades_copy = self.upgrades
        for index, value in pairs(self.upgrade_cards) do
            if index == 3 then
                local selected_buff = Lume.randomchoice(upgrades_copy["dive"])
                value:change_buff(selected_buff.buff , selected_buff.amount , selected_buff.des , function ()
                    DEPTH = DEPTH + 200
                    self.depth_text:update_Depth(DEPTH)
                end)
                break
            end

            local rarity = Lume.randomchoice({"common", "rare"})
            local selected_buff = Lume.randomchoice(upgrades_copy[rarity])
            value:change_buff(selected_buff.buff , selected_buff.amount , selected_buff.des)
        end

        self.state:change_state(self.starting_wave)
    end)
end

function Play:new()
    self.state = FSM(self , self.starting_wave)
    self.player = Player(900 , 180)
    self.camera = Camera(1 , self.player , 5)
    self.tilt = 0

    local smoke_image = love.graphics.newImage("assets/images/smoke.png")
    self.smoke = love.graphics.newParticleSystem(smoke_image, 1000)
    self.smoke:setParticleLifetime(1, 3)      -- Each smoke particle lives between 2 and 5 seconds
    self.smoke:setEmissionRate(150)
    self.smoke:setSizeVariation(0)
    self.smoke:setEmissionArea("borderrectangle", 472/2 + 16, 360/2 + 16)
    self.smoke:setSizes(1.0, 2 , 1.5)
    self.smoke:setSpin(-2, 2) 
    
    self.floor_images = {
        "assets/images/floors/floor1.png",
        "assets/images/floors/floor2.png",
        "assets/images/floors/floor3.png",
        "assets/images/floors/floor4.png",
        "assets/images/floors/floor5.png",
        "assets/images/floors/floor6.png",
        "assets/images/floors/floor7.png"
    }

    self.floor_index = 1

    self.floor = Sprite({
        image = self.floor_images[self.floor_index],
        origin = {0, 0},
        center_origin = false,
    })

    self.depth_text = Depth(640 , 360)

    self.font = love.graphics.newFont("assets/fonts/RubikMonoOne-Regular.ttf", 24)
    self.crosshair = Sprite({
        image = "assets/images/crosshair.png",
        origin = {8 , 8},
        offset = {-12 , -12},
        center_origin = true,
    })

    self.upgrade_cards = {
        Upgrade(32 , 480),
        Upgrade(16 + 223 , 480),
        Upgrade(640 - (177) , 480)
    }

    self.upgrades = {
        ["common"] = {
        {buff  = "buff_shot_delay" , amount = -0.1, des = "-shot delay"},
        {buff  = "buff_move_speed" , amount = 100, des = "+move speed"},
        },

        ["rare"] = {
            {buff  = "buff_bullet_speed" , amount = 10, des = "+bullet speed"},
            {buff  = "buff_shot_delay" , amount = -0.02, des = "-shot delay"},
        },

        ["dive"] = {
            {buff  = "buff_shot_delay" , amount = -0.1, des = "-shot delay"},
        }
    }

    self.spawnable_enemies = {
        [1200] = {
            {type = "pickaxe_enemy", chance = 0.4},
            {type = "fireball_enemy", chance = 0.4},
            {type = "bomb_enemy", chance = 0.2},
        },

        [1000] = {
            {type = "pickaxe_enemy", chance = 0.4},
            {type = "fireball_enemy", chance = 0.4},
            {type = "tnt_enemy", chance = 0.2},
        },

        [800] = {
            {type = "pickaxe_enemy", chance = 0.4},
            {type = "spark_enemy", chance = 0.4},
            {type = "tnt_enemy", chance = 0.2},
        },

        [600] = {
            {type = "spark_enemy", chance = 0.4},
            {type = "shovel_enemy", chance = 0.4},
            {type = "tnt_enemy", chance = 0.2}
        },

        [400] = {
            {type = "shovel_enemy" ,chance = 0.5},
            {type = "spark_enemy", chance = 0.5,},

        },

        [200] = {
            {type = "shovel_enemy", chance = 1.0}
        },

        [0] = {
            {type = "dummy_enemy", chance = 1.0}
        },
    }

    self.song = love.audio.newSource("assets/music/NotSureForDEEPERWIP1.mp3", "stream")
    self.song:setLooping(true)
    -- self.song:play()

    self.enemy_index = {
        ["dummy_enemy"] = Dummy,
        ["pickaxe_enemy"] = Dummy,
        ["fireball_enemy"] = Dummy,
        ["bomb_enemy"] = Dummy,
        ["tnt_enemy"] = Dummy,
        ["spark_enemy"] = Dummy,
        ["shovel_enemy"] = Dummy,
    }

    self.bullets = {}
    self.wave = {}
    self.enemies = {}
    self.hitboxes = {}
    self.hurtboxes = {}
    self.GUI = {}
    self.sortable_objects = {self.player}
    
    self:register_events()

    Event.dispatch("new_wave")
end

function Play:load()
    
end

function Play:create_wave()
    self.wave = {}
    local keys = {}
    for depth, value in pairs(self.spawnable_enemies) do
       table.insert(keys , depth) 
    end
    table.sort(keys , function (a , b)
        return a > b
    end)

    for _, value in ipairs(keys) do
        if DEPTH >= value then
            -- Log(value)
            for i = 1, 6, 1 do
                local spawns = self.spawnable_enemies[value]
                table.insert(self.wave , self:chooseEnemyToSpawn(self.spawnable_enemies[value]))
            end

            for index, value in ipairs(self.wave) do
                -- Log(value)
            end
            break
        end
    end

    for index, value in ipairs(self.wave) do
        local enemy = self.enemy_index[value](Lume.random(0 , 472 - 64) , Lume.random(0 , 360 - 64))
        Event.dispatch("add_enemy" , enemy)
    end
end

function Play:chooseEnemyToSpawn(enemyList)
    local total = 0
    for _, e in ipairs(enemyList) do
        total = total + e.chance
    end


    local r = math.random() * total
    local sum = 0
    for _, e in ipairs(enemyList) do
        sum = sum + e.chance
        if r <= sum then
            return e.type
        end
    end
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
    self.depth_text:update(dt)

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

function Play:ending_wave(dt)
    self.camera:update(dt)
    self.tilt = Utils.move_to(self.tilt , -0.2 , dt/2)
    self.player.x = self.player.x - dt * 300
    Event.dispatch("cam_shake" , 6 , 0.2)
    self.player.animator.rot =  self.player.animator.rot - 5 * dt
    if self.player.x <= -400 then
        self.state:change_state(self.upgrading)
    end
end

function Play:starting_wave(dt)
    self.camera:update(dt)
    self.tilt = Utils.move_to(self.tilt , -0.2 , dt/2)
    self.player.x = self.player.x - dt * 300
    Event.dispatch("cam_shake" , 6 , 0.2)
    self.player.animator.rot =  self.player.animator.rot - 5 * dt
    for index, card in ipairs(self.upgrade_cards) do
        card.y = Utils.lerp(card.y , 470 , dt * 2)
    end
    if self.player.x <= 360 + 12 then
        self.player.anim_rot = 0
        self.state:change_state(self.play)
    end
end

function Play:upgrading(dt)
    for index, card in ipairs(self.upgrade_cards) do
        card.y = Utils.lerp(card.y , 92 , dt * 2)
    end

    for index, card in ipairs(self.upgrade_cards) do
        card:update(dt)
    end

    if love.keyboard.isDown("space") then
        Event.dispatch("new_wave")
    end
end

function Play:pause(dt)
    
end

function Play:mousepressed(x , y , button)
    self.player:keypressed(x , y , button)
    Event.dispatch(self.upgrade_cards[1].buff_name , self.upgrade_cards[1].buff_amount)
    for index, card in ipairs(self.upgrade_cards) do
        card:mousepressed(x, y, button)
    end
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

function Play:draw_gui()
    love.graphics.setFont(self.font)
    self.depth_text:draw()

        for index, card in ipairs(self.upgrade_cards) do
            if card.y < 360 then
                card:draw()
            end
        end
    self.crosshair:draw(Pushed_Mouse.x , Pushed_Mouse.y)
end

function Play:draw()
    love.graphics.push()
        love.graphics.scale(self.camera.zoom)
        love.graphics.translate(-self.camera.x, -self.camera.y)
        love.graphics.rotate(self.tilt)
        self:draw_fight()
        love.graphics.setColor(Utils.color("11070a"))
        love.graphics.rectangle("fill", -450, -24, 450, 360)
        love.graphics.rectangle("fill", 472, -24, 490, 360)
        love.graphics.setColor(Utils.color())
        love.graphics.draw(self.smoke, 236, 180)
    love.graphics.pop()

    self:draw_gui()
end

