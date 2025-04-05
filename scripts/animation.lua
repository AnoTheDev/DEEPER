Animation = Object:extend()

--DO NOT PLAY AN ANIMATION CONSTANTLY IN AN UPDATE AND TRY TO SWITCH TO ANOTHER
require "scripts.sprite"
require "scripts.timer"

function Animation:new(parent)
    self.animations = {}
    self.events = {}
    self.current_frame = 1
    self.current_animation = ""
    self.previous_animation = ""
    self.current_sprite = nil
    self.parent = parent
    self.flip_x = false
    self.flip_y = false
    self.scale = {1, 1}
    self.rot = 0
    self.tick = 0
    self.looping = false
    self.frame_duration = 0.5
    self.done = false
    self.active = true
    self.dodge_ghosts = {}
    self.ghost_timer = Timer()
    self.ghosting = false
    self.flash_amount = 0
    self.flash_speed = 5
    self.shake_offset = {x = 0 , y = 0}
    self.hide = false
    self.shaking = false
    self.shake_amount = 10
    self.shake_timer = Timer()
    self.hit_shader = love.graphics.newShader([[
        extern float flash_amount;
    
        float noise(vec2 st) {
            return fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123);
        }
        
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(texture , texture_coords);
            vec3 flash = vec3(1.0);
            
            vec3 new_color = mix(pixel.rgb , flash , flash_amount);
            
            return vec4(new_color, pixel.a) * color;
        }
    
        ]])
end

function Animation:update(dt)
    if self.active == false then
        return
    end

    self:aniamte(dt)

    for _, sync in ipairs(self.events) do
        local event = sync.call

        if sync.name == self.current_animation then
            if sync.frame == self.current_frame then
                event()
            end
        end
    end

    self.hit_shader:send("flash_amount" , self.flash_amount)
    self.flash_amount = math.max(self.flash_amount - self.flash_speed * dt , 0)

    self.shake_timer:update(dt)
    if self.shaking == true then
        self.shake_offset = {x = Lume.random(-self.shake_amount , self.shake_amount),
        y = Lume.random(-self.shake_amount , self.shake_amount)}
    else
        self.shake_offset = {x = 0 , y = 0}
    end
end

function Animation:aniamte(dt)
    if Utils.is_in_list(self.animations, self.current_animation) then
        self.tick = self.tick + dt
        if self.tick > self.frame_duration then
            self.tick = 0
            local previous_frame = self.current_frame

            if self.looping then
                self.current_frame = (self.current_frame % #self.animations[self.current_animation]) + 1
            else
                self.current_frame = math.min(self.current_frame + 1, #self.animations[self.current_animation])
            end

            if self.current_frame ~= previous_frame then
                for _, sync in ipairs(self.events) do
                    if sync.name == self.current_animation and sync.frame == self.current_frame then
                        sync.call()
                    end
                end
            end
        end
    end
end

function Animation:dodge_ghosts_update(dt)
    for _, ghost in ipairs(self.dodge_ghosts) do
        ghost.alpha = Utils.lerp(ghost.alpha, 0, dt * 15)
    end
end

function Animation:flash(flash_speed)
    self.flash_amount = 1
    self.flash_speed = flash_speed or 5
end

function Animation:shake(amount , time)
    self.shake_amount = amount
    self.shaking = true
    local time = time or 0.1
    self.shake_timer:start(time , function ()
        self.shaking = false
    end)
end

function Animation:targeting(dt , param , speed)
    local targeting_speed = speed or 2

    if param.scale ~= nil then
        self.scale[1] = Utils.lerp(self.scale[1] , param.scale[1] , dt * targeting_speed)
        self.scale[2] = Utils.lerp(self.scale[2] , param.scale[2] , dt * targeting_speed)
    end
    
    if param.rot ~= nil then
        self.rot = Utils.lerp(self.rot , param.rot , dt * targeting_speed)
    end
end

function Animation:add(path, name, frame_origin , center_origin , offset)
    local files = love.filesystem.getDirectoryItems(path)
    self.animations[name] = {}

    for _, value in ipairs(files) do
        local new_sprite = Sprite({
            image = path .. "/" .. value,
            parent = self,
            origin = frame_origin,
            center_origin = center_origin,
            offset = offset or {0, 0}
        })
        table.insert(self.animations[name], new_sprite)
    end
end


function Animation:play(name , looping , frame_dur , call)
    if name == self.current_animation then
        return
    end

    if call ~= nil then
        call()
    end
    
    self.current_frame = 1
    self.previous_animation = self.current_animation
    self.current_animation = name
    self.looping = looping
    self.frame_duration = frame_dur or self.frame_duration

    if self.done == true then
        self.current_frame = 1
        self.done = false
    end
end

function Animation:pause()
    self.active = false
end

function Animation:resume()
    self.active = true
end

function Animation:restart(name , looping , frame_dur , call)
    if self.done == false then
        return
    end

    if call ~= nil then
        call()
    end
    
    self.current_frame = 1
    self.previous_animation = self.current_animation
    self.current_animation = name
    self.looping = looping
    self.frame_duration = frame_dur or self.frame_duration

    if self.done == true then
        self.current_frame = 1
        self.done = false
    end

end
    

function Animation:add_event(anim_name , target_frame , callback)
    table.insert(self.events , {call = callback , name = anim_name , frame = target_frame})
end

-- function Animation:add_callback(name , frame , call)
--     self.animation_callbacks[name] = {}
--     self.animation_callbacks[name][frame] = call
-- end


function Animation:draw(x , y)
    if self.hide == true then
        return
    end

    if self.animations[self.current_animation] == nil then
        return
    end

    local current_sprite = self.animations[self.current_animation][self.current_frame]
    current_sprite.scale = {self.scale[1], self.scale[2]}
    current_sprite.flip_x = self.flip_x
    current_sprite.flip_y = self.flip_y
    current_sprite.rot = self.rot
    
    -- Use parent's offset and pass to the sprite's draw method
    local draw_x = x or self.parent.x
    local draw_y = x or self.parent.y

    love.graphics.setShader(self.hit_shader)
    current_sprite:draw(draw_x + self.shake_offset.x , draw_y + self.shake_offset.y)
    love.graphics.setShader()
end
