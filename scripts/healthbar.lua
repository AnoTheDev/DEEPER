HealthBar = Object:extend()

function HealthBar:new(x, y, max, bar_image, colors, name , flash_sound)
    self.x = x or 0
    self.y = y or 0
    self.rotation = 0

    -- Health values
    self.max_health = max
    self.current_health = max
    self.previous_health = max

    -- Visual assets
    self.bar_image = love.graphics.newImage(bar_image)
    self.colors = {
        bottom = colors[1], -- Base color of the bar
        middle = colors[2], -- Gradual health reduction color
        top = colors[3],
        flash = colors[4]
    }
    self.flash_sound = nil
    if flash_sound then
        self.flash_sound = love.audio.newSource(flash_sound , "static")
        self.flash_sound:setVolume(0.5)
    end
    self.current_top_color = self.colors.top
    self.name = name
    self.font = love.graphics.newFont("assets/fonts/gothic.otf", 26)
    self.font:setFilter("linear", "linear") -- Smooth font rendering

    -- Shake effect variables
    self.shake_amount = 0
    self.offset = { x = 0, y = 0 }

    -- Animation timing
    self.fill_wait = 0
    self.flash_timer = Timer()
end

function HealthBar:update_health(amount)
    self.fill_wait = 0 -- Reset the wait time for smooth animation
    local prev_health = self.current_health
    self.current_health = amount

    -- Shake effect based on damage taken
    local damage_taken = prev_health - self.current_health
    self.shake_amount = math.min(20, damage_taken / 0.5)
end

function HealthBar:update(dt)
    -- Gradually update the previous health to catch up with the current health
    self.fill_wait = self.fill_wait + dt
    if self.fill_wait >= 0.8 then
        self.previous_health = Utils.move_to(self.previous_health, self.current_health, dt * 200)
    end

    -- Update shake effect over time
    local shake_target = (self.current_health/self.max_health) * 100 > 20 and 0 or self.current_health ~= 0 and 8 or 0
    if shake_target ~= 0 then
        self:flash(dt)
    end
    self.shake_amount = math.max(self.shake_amount - dt * 15, shake_target)
    self.offset.x = Lume.random(-self.shake_amount, self.shake_amount)
    self.offset.y = Lume.random(-self.shake_amount, self.shake_amount)
end

function HealthBar:flash(dt)
    if self.colors.flash == nil then
        return
    end

    self.flash_timer:update(dt)
    self.flash_timer:start(0.1 , function ()
        if self.flash_sound then
            self.flash_sound:play()
        end
        if self.current_top_color == self.colors.top then
            self.current_top_color = self.colors.flash
        else
            self.current_top_color = self.colors.top
        end
    end)
end

function HealthBar:draw()
    local x_pos = self.x + self.offset.x
    local y_pos = self.y + self.offset.y

    -- Draw the health bar background
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colors.bottom)
    love.graphics.draw(self.bar_image, x_pos, y_pos)

    -- Calculate health bar fill sizes
    local fill_width = (self.current_health / self.max_health) * self.bar_image:getWidth()
    local fill_middle = (self.previous_health / self.max_health) * self.bar_image:getWidth()

    -- Draw the middle (previous health) fill
    love.graphics.setColor(self.colors.middle)
    love.graphics.setScissor(x_pos, y_pos, fill_middle, self.bar_image:getHeight())
    love.graphics.draw(self.bar_image, x_pos, y_pos)
    love.graphics.setScissor()

    -- Draw the top (current health) fill
    love.graphics.setColor(self.current_top_color)
    love.graphics.setScissor(x_pos, y_pos, fill_width, self.bar_image:getHeight())
    love.graphics.draw(self.bar_image, x_pos, y_pos)
    love.graphics.setScissor()

    -- Reset color to default
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the optional icon, if present
    if self.icon then
        love.graphics.draw(
            self.icon,
            self.x - (self.icon:getWidth() * self.icon_scale_x) + self.offset.x,
            self.y - (self.icon:getHeight() / 5) * self.icon_scale_y + self.offset.y,
            0,
            self.icon_scale_x,
            self.icon_scale_y
        )
    end

    -- Draw the boss/player name, if present
    if self.name then
        love.graphics.print(self.name, x_pos, y_pos - 18)
    end
end
