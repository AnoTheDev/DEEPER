SceneManager = Object:extend()

function SceneManager:new(scenes)
    self.scenes = scenes or {}
    self.previous_scene = nil
    self.current_scene = nil
end

function SceneManager:load(scene_name)
    if self.scenes[scene_name] == nil then
        Log("INVALID SCENE")
        return
    end

    self:change_scene(scene_name)
    -- self.current_scene = self.scenes[scene_name]
    -- self.current_scene:load()
end

function SceneManager:update(dt)
    if self.current_scene == nil then
        Log("INVALID SCENE")
        return
    end

    self.current_scene:update(dt)
end

function SceneManager:change_scene(scene_name , call)
    if self.scenes[scene_name] == nil then
        Log("tired to change to invalid state")
        return
    end
    
    if self.current_scene == nil then
        self.current_scene = self.scenes[scene_name]
        self.current_scene:load()
        return
    end

    self.current_scene:close()
    self.current_scene = self.scenes[scene_name]
    self.current_scene:load()
end

function SceneManager:keypressed(key)
    self.current_scene:keypressed(key)
end

function SceneManager:mousepressed(x , y , button)
    self.current_scene:mousepressed(x , y , button)
end

function SceneManager:draw()
    if self.current_scene == nil then
        Log("INVALID SCENE")
        return
    end

    self.current_scene:draw()
end