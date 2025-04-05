FSM = Object:extend()

function FSM:new(target, initial_state)
    self.target  = target
    self.previous_state = nil
    self.current_state = initial_state
end

function FSM:update(dt)
    if self.current_state == nil then
        Terminal:print("INVALID STATE")
        return
    end

    self.current_state(self.target , dt)
end


function FSM:change_state(target_state , call)
    if target_state == self.current_state then
        return
    end
    if call ~= nil then
       call() 
    end
    self.previous_state = self.current_state
    self.current_state = target_state
end