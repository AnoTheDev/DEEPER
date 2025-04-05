love.graphics.setDefaultFilter("nearest", "nearest")
require "settings"

local game

function love.load()
    game = Game()
end

local function update_mouse_position()
    local mouse_x, mouse_y = love.mouse.getPosition()
    local game_x, game_y = Push:toGame(mouse_x, mouse_y)

    if game_x and game_y then
        Pushed_Mouse.x, Pushed_Mouse.y = game_x, game_y
        Pushed_Mouse.real_x, Pushed_Mouse.real_y = Push:toGame(mouse_x, mouse_y)
    end
end

function love.update(dt)
    game:update(dt)
    update_mouse_position()
end

function love.mousepressed(x, y, button)
    game:mousepressed(x, y, button)
    love.touchpressed(1, Pushed_Mouse.x, Pushed_Mouse.y, 0, 0, 1)
end

function love.mousereleased(x, y, button)
    love.touchreleased(1, Pushed_Mouse.x, Pushed_Mouse.y, 0, 0, 1)
end

function love.mousemoved(x, y)

end

function love.keypressed(key)
    game:keypressed(key)
end

function love.resize(w, h)
    Push:resize(w, h)
    -- Terminal:print(w..":" ..h)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    game:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y)
    game:touchmoved(id, x, y)
end

function love.touchreleased(id, x, y)
    game:touchreleased(id, x, y)
end

function love.draw()
    Push:start()
    love.graphics.setColor(Utils.color("002776"))
    love.graphics.rectangle("fill", 0, 0, WORLD_SIZE.WIDTH, WORLD_SIZE.HEIGHT)
    love.graphics.setColor(Utils.color())
    game:draw()
    Push:finish()
    Terminal:draw()
end