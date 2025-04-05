Utils = {}

local base_tile_path = "images/tiles/"

function Utils.remove_from_list(arr, target)
    for index , value in ipairs(arr) do
        if value == target then
            table.remove(arr , index)
        end
    end
end

function Utils.clear_list(list)
    for key, value in pairs(list) do
        table.remove(list , key)
    end
end

function Utils.is_in_list(arr, value)
    for _ , v in ipairs(arr) do
        if v == value then
            return true
        end
    end

    if arr[value] ~= nil then
        return true
    end

    return false
end

function Utils.find_index(list, target)
    for i , v in ipairs(list) do
        if v == target then
            return i
        end
    end
    return nil
end

function Utils.distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function Utils.center(x1, y1, x2, y2)
    local centerX = (x1 + x2) / 2
    local centerY = (y1 + y2) / 2
    return {x = centerX , y = centerY}
end


function Utils.lerp(a, b, t, epsilon)
    epsilon = epsilon or 0.001 -- Default threshold for convergence

    -- If the difference between a and b is smaller than epsilon, return b immediately
    if math.abs(b - a) < epsilon then
        return b
    end

    t = math.max(0, math.min(1, t)) -- Clamp t between 0 and 1

    -- Check if the lerp is very close to its destination, stop early if so
    local result = a + (b - a) * t
    if math.abs(result - b) < epsilon then
        return b -- Snap to target once we are close enough
    end

    return result
end


function Utils.lerp_angle(a, b, t)
    local diff = (b - a + 180) % 360 - 180
    return a + diff * t
end

function Utils.color(r, g, b, a)
    if type(r) == "string" then
        local hex = r:gsub("#", "") -- Remove # if present
        local red = tonumber(hex:sub(1, 2), 16) / 255
        local green = tonumber(hex:sub(3, 4), 16) / 255
        local blue = tonumber(hex:sub(5, 6), 16) / 255
        local alpha = g ~= nil and g or 1
        return {red , green , blue , alpha}
    end

    local red = r ~= nil and r/255 or 1
    local green = g ~= nil and g/255 or 1
    local blue = b ~= nil and b/255 or 1
    local alpha = a ~= nil and a/255 or 1

    return {red , green , blue , alpha}
end

function Utils.wrap(x, min, max)
    local range = max - min
    return min + ((x - min) % range + range) % range
end

function Utils.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

function Utils.move_to(current , target , speed)
    local difference = target - current
    if math.abs(difference) <= speed then
        return target
    end

    return current + Utils.sign(difference) * speed
end

return Utils