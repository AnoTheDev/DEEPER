Display_Pattern = Object:extend()

function Display_Pattern:new(pos , pattern, color)
    self.pattern = pattern
    self.color = color or Lume.randomchoice({"red", "blue", "green", "yellow"})
    self.blocks = {}
    self.x = pos.x or 0
    self.y = pos.y or 0 
    self.draw_x = self.x
    self.draw_y = self.y
    self.dragging = false
    self.scale = 3
    self.size = 16 * self.scale * 3
    self.prediction_blocks = {}
    
    for row_index, row in ipairs(pattern) do
        for column_index, column in ipairs(row) do
            if column == 1 then  -- Assuming 1 represents a block in the pattern
                local block = Block({x = self.x + (column_index - 1) * 16 * self.scale, y = self.y + (row_index - 1) * 16 * self.scale}, self.color)
                block.scale = self.scale
                block.offset = {x = (column_index-1) * 16 * self.scale , y = (row_index-1) * 16 * self.scale}
                table.insert(self.blocks, block)
            end
        end
    end
end

function Display_Pattern:update(dt)
    if self.dragging ==  false then
        self.draw_x = Utils.lerp(self.draw_x , self.x , dt * 10)
        self.draw_y = Utils.lerp(self.draw_y , self.y , dt * 10)
    end

end


function Display_Pattern:draw(x , y , scale)
    local new_x = x or self.draw_x
    local new_y = y or self.draw_y
    local size = scale or self.scale

    for _, block in ipairs(self.blocks) do
        if self.dragging == true then
            block:draw(new_x + block.offset.x, new_y + block.offset.y , size)
        end
        block:draw(new_x + block.offset.x, new_y + block.offset.y , size)
    end
end