Game = Object:extend()

function Game:new()
   self.mockup = love.graphics.newImage("assets/markup.png")
   self.state = FSM(self, self.play_state)
   self.grid_size = 16
   self.grid_scale = 3
   self.grid_position = {x = 80, y = 160}
   self.current_grid = {x = 1, y = 1}
   self.colors = {"red", "blue", "green", "yellow"}
   self.patterns = self:initialize_patterns()
   self.block_previews = self:initialize_block_previews()
   self.block_count = 0
   self.current_block = nil
   self.grid = self:initialize_grid(8, 8)
   self.grid_placement_offset = {x = -1 , y = -1}
   self.score = Score()
   self.per_block_score = 10
   self.streak = 0
   self.floats = {}
   self.font = love.graphics.newFont("assets/fonts/jetbrains.ttf" , 64)
   local shader_code = love.filesystem.read("shaders/menu.glsl")
   self.background_shader = love.graphics.newShader(shader_code)
end

function Game:initialize_patterns()
   return {
      -- L Block Variants
      {{1, 0}, {1, 0}, {1, 1}},
      {{1, 1, 1}, {1, 0, 0}},
      {{1, 1}, {0, 1}, {0, 1}},
      {{0, 0, 1}, {1, 1, 1}},
      {{0, 1}, {0, 1}, {1, 1}},
      {{1, 1}, {1, 0}, {1, 0}},
      {{1, 0}, {1, 1}},
      {{1, 1}, {1, 0}},
      {{1, 1}, {0, 1}},
      {{0, 1}, {1, 1}},
      {{0, 1}, {1, 1}},
      {{1, 1}, {1, 0}},
  
      -- T Block Variants
      {{1, 1, 1}, {0, 1, 0}},
      {{0, 1}, {1, 1}, {0, 1}},
      {{0, 1, 0}, {1, 1, 1}},
      {{1, 0}, {1, 1}, {1, 0}},
  
      -- Square Block (Only One, No Rotation Needed)
      {{1, 1}, {1, 1}},
  
      -- I Block Variants
      {{ 0 ,1 , 0}, { 0 , 1 , 0}, { 0 , 1 , 0}, { 0 , 1 , 0}},
      {{1, 1, 1, 1}},
      {{ 0 ,1 , 0}, { 0 , 1 , 0}, { 0 , 1 , 0}},
      {{1, 1, 1}},
      {{ 0 , 1 , 0}, { 0 , 1 , 0}},
      {{1, 1}},
  
      -- Z Block Variants
      {{1, 1, 0}, {0, 1, 1}},
      {{0, 1}, {1, 1}, {1, 0}},
      {{0, 1, 1}, {1, 1, 0}}
  }  
    
end

function Game:initialize_block_previews()
   local previews = {}
   local pattern_copy = self.patterns
   local color_copy = self.colors
   for i = 1, 3 do
      local pattern = Lume.randomchoice(pattern_copy)
      local color = Lume.randomchoice(color_copy)
      table.insert(previews, Display_Pattern({x = 8 + (i - 1) * 176, y = 656}, pattern, color))
      Utils.remove_from_list(pattern_copy , pattern)
      Utils.remove_from_list(color_copy , color)
   end
   return previews
end

function Game:initialize_grid(rows, cols)
   local grid = {}
   for i = 1, rows do
      grid[i] = {}
      for j = 1, cols do
         grid[i][j] = 0
      end
   end
   return grid
end

function Game:update(dt)
   Log(self.streak)
   self.state:update(dt)
   self.score:update(dt)
   self:moveDrag(Pushed_Mouse.x, Pushed_Mouse.y)
   self.background_shader:send("resolution", {960,540})
   self.background_shader:send("time", love.timer.getTime())
end

function Game:menu_state(dt)
   -- Menu state logic
end

function Game:play_state(dt)
   self:grid_control()
   for _, preview in ipairs(self.block_previews) do
      preview:update(dt)
   end

   for index, float in ipairs(self.floats) do
      float:update(dt)
   end
end

function Game:to_grid(x, y)
   local x_grid = math.floor((x - self.grid_position.x) / (self.grid_size * self.grid_scale)) + 1
   local y_grid = math.floor((y - self.grid_position.y) / (self.grid_size * self.grid_scale)) + 1
   return x_grid, y_grid
end

function Game:grid_control()
   local x_grid = math.floor((Pushed_Mouse.x - self.grid_position.x) / (self.grid_size * self.grid_scale)) + 1
   local y_grid = math.floor((Pushed_Mouse.y - self.grid_position.y) / (self.grid_size * self.grid_scale)) + 1

   if x_grid > 0 and x_grid <= #self.grid[1] and y_grid > 0 and y_grid <= #self.grid + 1 then
      self.current_grid = {x = x_grid, y = y_grid}
   else
      self.current_grid = {x = 0, y = 0}
   end
end

function Game:check_grid_full()
   -- Check for full rows
   self.per_block_score = 10 + (math.ceil(self.streak) * 2)
   local target_score = 0
   local multiplier = 0
   local blocks_removed = false
   for row_index, row in ipairs(self.grid) do
      local full = true
      for _, column in ipairs(row) do
         if column == 0 then
            full = false
            break
         end
      end
      if full then
         multiplier = multiplier + 1
         for column_index = 1, #row do
            self.grid[row_index][column_index] = 0
            target_score = target_score + self.per_block_score
            blocks_removed = true
         end
      end
   end

   -- Check for full columns
   for column_index = 1, #self.grid[1] do
      local full = true
      for row_index = 1, #self.grid do
         if self.grid[row_index][column_index] == 0 then
            full = false
            break
         end
      end
      if full then
         multiplier = multiplier + 1
         for row_index = 1, #self.grid do
            self.grid[row_index][column_index] = 0
            target_score = target_score + self.per_block_score
            blocks_removed = true
         end
      end
   end
   
   if blocks_removed == true then
      self.streak = self.streak + 1
   else
      self.streak = math.max(self.streak - 0.5, 0)
   end

   self.score:update_score(self.score.value + target_score * multiplier)

   if blocks_removed == true then
      local text = "+" .. tostring(target_score * multiplier)
      local streak_text = "X".. tostring(self.streak) 
      table.insert(self.floats , Float_Text(WORLD_SIZE.WIDTH/2 , WORLD_SIZE.HEIGHT/2 , text))
      table.insert(self.floats , Float_Text(200 , WORLD_SIZE.HEIGHT/2 , streak_text))
   end
end

function Game:check_placement(x , y)
   if self.current_block == nil then
      return
   end

   local pattern = self.current_block.pattern

   for row_index, row in ipairs(pattern) do
      for col_index, block in ipairs(row) do
         if block == 1 then
            local check_x = x + col_index - 1
            local check_y = y + row_index - 1
            if self.grid[check_y] == nil or self.grid[check_y][check_x] ~= 0 then
               return false
            end
         end
      end
   end
end

function Game:place_block(x, y)
   if self.current_block == nil then
      return
   end

   local pattern = self.current_block.pattern
   local color = self.current_block.color

   if self:check_placement(x , y) == false then return end

   for row_index, row in ipairs(pattern) do
      for col_index, block in ipairs(row) do
         if block == 1 then
            local grid_x = x + col_index - 1
            local grid_y = y + row_index - 1
            local block_x = self.grid_position.x + (grid_x * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale)
            local block_y = self.grid_position.y + (grid_y * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale)
            local new_block = Block({x = block_x, y = block_y}, color)
            self.grid[grid_y][grid_x] = new_block
         end
      end
   end

   self:check_grid_full()
   local new_block = Display_Pattern({x = self.current_block.x, y = self.current_block.y}, Lume.randomchoice(self.patterns), Lume.randomchoice(self.colors))
   for index, preview in ipairs(self.block_previews) do
      if preview == self.current_block then
         table.remove(self.block_previews, index)
         self.current_block = nil
         break
      end
   end
end

function Game:spawn_more_blocks()
   self.patterns = self:initialize_patterns()
   self.block_previews = self:initialize_block_previews()
end

function Game:check_block_preview(x, y)
   for index, block in ipairs(self.block_previews) do
      if x >= block.x and x <= block.x + block.size and y >= block.y and y <= block.y + block.size then
         self.current_block = block
      end
   end
end

function Game:startDrag(x, y)
   if self.current_block == nil then
      self:check_block_preview(x, y)
      if self.current_block == nil then
         return
      end
   end

   if x >= self.current_block.x and x <= self.current_block.x + self.current_block.size and y >= self.current_block.y and y <= self.current_block.y + self.current_block.size then
      self.current_block.dragging = true
      self.current_block.offsetX = x - self.current_block.x
      self.current_block.offsetY = y - self.current_block.y
      self.prediction_blocks = self.current_block.blocks
   end
end

function Game:moveDrag(x, y)
   if self.current_block == nil then
      return
   end

   if self.current_block.dragging then
      self.current_block.draw_x = Utils.lerp(self.current_block.draw_x , x - 64 , 0.6)
      self.current_block.draw_y = Utils.lerp(self.current_block.draw_y , y - 64 , 0.6)
   end
end

function Game:stopDrag(x, y)
   if self.current_block == nil then
      return
   end

   self.current_block.dragging = false
   self:place_block(self.current_grid.x + self.grid_placement_offset.x, self.current_grid.y + self.grid_placement_offset.y)
   self.current_block = nil

   if #self.block_previews <= 0 then
      self:spawn_more_blocks()
   end
end

function Game:mousepressed(x, y, button)
   -- self:place_block(self.current_grid.x, self.current_grid.y)
end

function Game:mousemoved(x, y)
   -- Mouse moved logic
end

function Game:keypressed(key)
   if key == "i" then
      self:spawn_more_blocks()
   end

   if key == "-" then
      table.insert(self.floats , Float_Text(WORLD_SIZE.WIDTH/2 , WORLD_SIZE.HEIGHT/2 , text))
      table.insert(self.floats , Float_Text(200 , WORLD_SIZE.HEIGHT/2 , streak_text))
   end
end

function Game:touchpressed(id, x, y, dx, dy, pressure)
   self:startDrag(x, y)
end

function Game:touchmoved(id, x, y)
   -- Touch moved logic
end

function Game:touchreleased(id, x, y)
   self:stopDrag(x, y)
end

function Game:draw()
   love.graphics.setShader(self.background_shader)
      love.graphics.rectangle("fill" , 0 , 0 , WORLD_SIZE.WIDTH , WORLD_SIZE.HEIGHT)
   love.graphics.setShader()
   love.graphics.setFont(self.font)
   love.graphics.setColor(Utils.color("#001237"))
   love.graphics.rectangle('fill', self.grid_position.x, self.grid_position.y, #self.grid * self.grid_size * self.grid_scale, #self.grid[1] * self.grid_size * self.grid_scale, 12, 12)
   love.graphics.setColor(Utils.color(255, 255, 255, 255))
   love.graphics.setLineWidth(2)
   love.graphics.setColor(Utils.color("#002cdb" , 0.05))

   for row_index, rows in ipairs(self.grid) do
      for column_index, columns in ipairs(rows) do
         love.graphics.rectangle("line",
            self.grid_position.x + (column_index * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale),
            self.grid_position.y + (row_index * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale),
            self.grid_size * self.grid_scale, self.grid_size * self.grid_scale --[[ 12 , 12 , 5 ]]
         )
      end
   end

   love.graphics.setColor(Utils.color())

   for index, row in ipairs(self.grid) do
      for _, block in ipairs(row) do
         if block ~= 0 then
            love.graphics.draw(block.block_image, block.grid_position.x, block.grid_position.y, 0, block.scale, block.scale)
         end
      end
   end

   if self:check_placement(self.current_grid.x + self.grid_placement_offset.x, self.current_grid.y + self.grid_placement_offset.y) ~= false then
      love.graphics.setColor(1, 1, 1, 0.2)
   else
      love.graphics.setColor(1, 0, 0, 0.6)
   end
   
   if self.current_block and self.current_grid.x ~= 0 then
      self.current_block:draw(self.grid_position.x + ((self.current_grid.x - 1) * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale),
      self.grid_position.y + ((self.current_grid.y - 1) * self.grid_size * self.grid_scale) - (self.grid_size * self.grid_scale), 3)
   end
   
   love.graphics.setColor(Utils.color())
   
   for _, preview in ipairs(self.block_previews) do
      if preview.dragging == true then
         -- love.graphics.setColor(0.5 , 0.5 , 0.5 , 0.4)
      end
      preview:draw(nil, nil, 3)
      love.graphics.setColor(Utils.color())
   end

   self.score:draw()

   for index, float in ipairs(self.floats) do
      float:draw()
   end
end
