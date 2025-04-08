Object = require "libs.classic"
Utils = require "libs.utils"
Push = require "libs.push"
Lume = require "libs.lume"
Event = require "libs.event"
require "libs.console"
require "game"
Terminal = Console({ size = 8 })
DEBUGGING = false
require "scripts.FSM"
require "scripts.animation"
require "scripts.sprite"
require "scripts.timer"
require "scripts.camera"
require "scripts.button"
require "scripts.hurtbox"
require "scripts.hitbox"
require "scripts.scene_manager"
require "scene.play"
require "src.player.player"
require "src.enemies.enemy"
require "src.enemies.dummy.dummy"
require "src.enemies.dummy.pickaxe"
require "src.depth"
require "src.Gui.upgrade"

WORLD_SIZE = {WIDTH =  640, HEIGHT = 360}
local desktopWidth, desktopHeight = love.graphics.getDimensions()
WINDOW_WIDTH, WINDOW_HEIGHT = desktopWidth * 0.7, desktopHeight * 0.7

Push:setupScreen(WORLD_SIZE.WIDTH, WORLD_SIZE.HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen = false, resizable = true})
Push:switchFullscreen()
Push:switchFullscreen()
Push._borderColor = Utils.color("000000")

Pushed_Mouse = {x = 0, y = 0, real_x = 0, real_y = 0 , cam_x = 0, cam_y = 0}

function Log(message)
    Terminal:print(message)
end

math.randomseed(os.time())
math.random(); math.random(); math.random()