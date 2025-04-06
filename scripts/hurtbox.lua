Hurtbox = Object:extend()

function Hurtbox:new(parent, x, y, width, height, event_name, offset_x, offset_y, damage, cumulative, angle , pivot_x , pivot_y)
    self.parent = parent
    self.x, self.y = x or 0, y or 0
    self.angle = angle or 0 -- Rotation angle in radians
    self.offset_x, self.offset_y = offset_x or 0, offset_y or 0
    self.width = width or 16
    self.height = height or 16
    self.pivot_x, self.pivot_y = pivot_x or 0, pivot_y or 0 -- Pivot set to the top-left corner
    self.damage_timer = Timer()
    self.damage = damage or 10
    self.active = true
    self.debug = DEBUGGING
    self.cumulative = cumulative or false
    self.already_collided = {}

    self.event = event_name
    Event.on("retrieve_boxes", function()
        Event.dispatch("add_hurtbox", self)
    end)

    Event.dispatch("add_hurtbox", self)
end

function Hurtbox:update(dt)
    self.x, self.y = self.parent.x + self.offset_x, self.parent.y + self.offset_y
end

-- Calculate the four vertices of the rotated rectangle
function Hurtbox:getVertices()
    local cx, cy = self.x + self.pivot_x, self.y + self.pivot_y -- Pivot point coordinates
    local cosA, sinA = math.cos(self.angle), math.sin(self.angle)

    -- Define unrotated vertices relative to the pivot
    local vertices = {
        {0, 0},                     -- Top-left
        {self.width, 0},            -- Top-right
        {self.width, self.height},  -- Bottom-right
        {0, self.height},           -- Bottom-left
    }

    -- Rotate each vertex around the pivot point
    for i, vertex in ipairs(vertices) do
        local local_x, local_y = vertex[1], vertex[2]
        local rotated_x = cx + (local_x * cosA - local_y * sinA)
        local rotated_y = cy + (local_x * sinA + local_y * cosA)
        vertices[i] = {rotated_x, rotated_y}
    end

    return vertices
end

-- Check if two polygons intersect using SAT (Separating Axis Theorem)
function Hurtbox:polygonIntersect(vertices1, vertices2)
    local function project(vertices, axis)
        local min, max = nil, nil
        for _, vertex in ipairs(vertices) do
            local projection = vertex[1] * axis[1] + vertex[2] * axis[2]
            if not min or projection < min then min = projection end
            if not max or projection > max then max = projection end
        end
        return min, max
    end

    local function overlap(min1, max1, min2, max2)
        return not (min1 > max2 or min2 > max1)
    end

    local function getAxes(vertices)
        local axes = {}
        for i = 1, #vertices do
            local p1, p2 = vertices[i], vertices[i % #vertices + 1]
            local edge = {p2[1] - p1[1], p2[2] - p1[2]}
            table.insert(axes, {-edge[2], edge[1]}) -- Perpendicular vector
        end
        return axes
    end

    local axes1 = getAxes(vertices1)
    local axes2 = getAxes(vertices2)

    for _, axis in ipairs(axes1) do
        local min1, max1 = project(vertices1, axis)
        local min2, max2 = project(vertices2, axis)
        if not overlap(min1, max1, min2, max2) then return false end
    end

    for _, axis in ipairs(axes2) do
        local min1, max1 = project(vertices1, axis)
        local min2, max2 = project(vertices2, axis)
        if not overlap(min1, max1, min2, max2) then return false end
    end

    return true
end

function Hurtbox:overlaped(box)
    if not self.active then return false end
    if not box.active then return false end

    -- Skip if too far (broad-phase optimization)
    if Utils.distance(self.x + self.width / 2, self.y + self.height / 2, box.x + box.width / 2, box.y + box.height / 2) > 150^2 then
        return false
    end

    -- Get vertices for both hurtboxes
    local vertices1 = self:getVertices()
    local vertices2 = box:getVertices()

    -- Check for polygon intersection
    if self:polygonIntersect(vertices1, vertices2) then
        if Utils.is_in_list(self.already_collided, box) and self.cumulative == true then
            return false
        end

        box:take_damage(self.damage, 1)

        -- Dispatch event if defined
        if self.event then
            self.event()
        end

        if self.cumulative == true then
            table.insert(self.already_collided, box)
        else
            self.active = false
        end

        return true
    end

    return false
end

function Hurtbox:draw()
    if not self.debug then return end

    local vertices = self:getVertices()
    love.graphics.setColor(Utils.color(0, 0, 255, 255))
    love.graphics.polygon("line", vertices[1][1], vertices[1][2], vertices[2][1], vertices[2][2],
        vertices[3][1], vertices[3][2], vertices[4][1], vertices[4][2])
    love.graphics.setColor(Utils.color())
end
