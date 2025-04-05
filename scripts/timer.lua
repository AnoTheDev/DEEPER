Timer = Object:extend()

Timer.timers = {}

function Timer:new()
    self.duration = 1
    self.callback = nil
    self.elapsed = 0
    self.active = false
    self.done = false
    table.insert(Timer.timers , self)
end

-- Update the timer
function Timer:update(dt)
    if self.active == true then
        -- Terminal:print(self.elapsed)
        self.elapsed = self.elapsed + dt
        if self.elapsed >= self.duration then
            if self.callback then
                self.callback()
            end
            self.active = false
            self.done = true
        end
    end
end

function Timer:start(dur , call)
    if self.active == true then
        return
    end
    self.active = true
    self.elapsed = 0
    self.duration = dur
    self.callback = call
    self.done = false
end

function Timer:stop()
    self.elapsed = 0
    self.callback = nil
    self.dur = 0
    self.done = false
    self.active = false
end

function Timer:restart()
    self.active = true
    self.elapsed = 0
    self.done = false
end

Timer.stop_all = function ()
    for index, timer in ipairs(Timer.timers) do
        timer:stop()
    end
end