Sprite = Object:extend()

function Sprite:new(params)
    self.flip_x = params.flip_x or false
    self.flip_y = params.flip_y or false
    self.rot = params.rot or 0
    self.image = love.graphics.newImage(params.image)
    self.offset = params.offset or { 0, 0 }
    self.scale = params.scale or { 1, 1 }
    self.width = self.image:getWidth()
    self.height = self.image:getHeight()
    self.origin = params.origin or { self.width / 2, self.height / 2 }
    self.mirror_rotation = params.mirror_rotation or false -- Allow external initialization
    self.center_origin = params.center_origin or false
    -- Default color for resetting
    self.default_color = { 1, 1, 1, 1 } -- White color

    self.flash_amount = 0
end

function Sprite:targeting(dt, params, speed)
    local targeting_speed = speed or 2

    -- Smoothly rotate towards target rotation
    if params.target_rot ~= nil then
        self.rot = Utils.lerp_angle(self.rot, params.target_rot, dt * targeting_speed)
    end

    -- Smoothly scale towards target scale
    if params.target_scale ~= nil then
        self.scale[1] = Utils.lerp(self.scale[1], params.target_scale[1], dt * targeting_speed)
        self.scale[2] = Utils.lerp(self.scale[2], params.target_scale[2], dt * targeting_speed)
    end
end

function Sprite:draw(x, y, rot, color)
    local offset_x, offset_y = self.offset[1], self.offset[2]
    local direction_x = self.flip_x and -1 or 1
    local direction_y = self.flip_y and -1 or 1

    -- Apply flipping to offsets if mirror_rotation is enabled
    if self.mirror_rotation then
        offset_x = offset_x * direction_x
        offset_y = offset_y * direction_y
    end

    -- Determine the rotation
    local rotation = rot or self.rot
    if self.mirror_rotation then
        rotation = rotation * direction_x * direction_y
    end

    -- Calculate the draw position (without adding origin)
    local draw_x = x + offset_x
    local draw_y = y + offset_y

    if self.center_origin == true then
        draw_x = draw_x + self.origin[1]
        draw_y = draw_y + self.origin[2]
    end

    -- Set color if provided, or use default
    if color then
        love.graphics.setColor(color)
    end

    -- Draw the sprite with proper origin for transformations
    love.graphics.draw(
        self.image,
        draw_x,
        draw_y,
        rotation,
        self.scale[1] * direction_x,
        self.scale[2] * direction_y,
        self.origin[1], -- Use origin here for scaling/rotation
        self.origin[2]
    )

    -- Reset color
    love.graphics.setColor(self.default_color)
end
