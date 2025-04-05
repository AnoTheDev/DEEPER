Object = require "libs.classic"
Utils = require "libs.utils"
Push = require "libs.push"
Lume = require "libs.lume"
Event = require "libs.event"
require "libs.console"
require "game"
Terminal = Console({ size = 8 })
require "scripts.FSM"
require "scripts.animation"
require "scripts.sprite"
require "scripts.timer"
require "scripts.camera"
require "scripts.button"
require "src.block"
require "src.display_pattern"
require "src.score"
require "src.floating_text"

WORLD_SIZE = { WIDTH = 540, HEIGHT = 960}
local desktopWidth, desktopHeight = 540 , 960
WINDOW_WIDTH, WINDOW_HEIGHT = desktopWidth , desktopHeight

Push:setupScreen(WORLD_SIZE.WIDTH, WORLD_SIZE.HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, { fullscreen = false, resizable = true})
Push._borderColor = Utils.color("000000")

Pushed_Mouse = { x = 0, y = 0, real_x = 0, real_y = 0}

function Log(message)
    Terminal:print(message)
end