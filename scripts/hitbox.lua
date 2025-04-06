Hitbox = Object:extend()

function Hitbox:new(parent, x, y, width, height, offset_x, offset_y, event, health)
    self.parent = parent
    self.x = x or 0
    self.y = y or 0
    self.width = width or 16
    self.height = height or 16
    self.offset_x, self.offset_y = offset_x or 0, offset_y or 0
    self.event = event
    self.damage_timer = Timer()
    self.active = true
    self.cool_time = 0.2
    self.health = health or 100
    self.debug = DEBUGGING
    self.angle = 0 -- Add rotation for consistency with Hurtbox

    Event.on("retrieve_boxes", function()
        Event.dispatch("add_hitbox", self)
    end)

    Event.dispatch("add_hitbox", self)
    
end

function Hitbox:take_damage(amount, cool)
    self.health = math.max(self.health - (amount or 1), 0)
    self.cool_time = cool
    if self.event then
        self.event(self.parent , amount)
    end
end

function Hitbox:update(dt)
    self.x, self.y = self.parent.x + self.offset_x, self.parent.y + self.offset_y
end

-- Calculate the vertices of the Hitbox, considering rotation
function Hitbox:getVertices()
    local hw, hh = self.width / 2, self.height / 2
    local cx, cy = self.x + hw, self.y + hh -- Center of the rectangle
    local cosA, sinA = math.cos(self.angle), math.sin(self.angle)

    return {
        {cx + (-hw * cosA - -hh * sinA), cy + (-hw * sinA + -hh * cosA)}, -- Top-left
        {cx + ( hw * cosA - -hh * sinA), cy + ( hw * sinA + -hh * cosA)}, -- Top-right
        {cx + ( hw * cosA -  hh * sinA), cy + ( hw * sinA +  hh * cosA)}, -- Bottom-right
        {cx + (-hw * cosA -  hh * sinA), cy + (-hw * sinA +  hh * cosA)}  -- Bottom-left
    }
end

-- Draw the Hitbox
function Hitbox:draw()
    if not self.debug then return end

    local vertices = self:getVertices()
    love.graphics.setColor(Utils.color(0, 255, 0, 255))
    love.graphics.polygon("line", vertices[1][1], vertices[1][2], vertices[2][1], vertices[2][2],
        vertices[3][1], vertices[3][2], vertices[4][1], vertices[4][2])
    love.graphics.setColor(Utils.color())
end
