local data = {}

blocks = {
  [1] = {
    id = 1,
    name = "grass",
    tex = {"grass_1.png", "grass_2.png"},
    texRefresh = 1000,
  },
  [2] = {
    id = 2,
    name = "water",
    tex = {"water_1.png", "water_2.png"},
    texRefresh = 500,
    collision = true,
  },
  [3] = {
    id = 3,
    name = "cobblestone",
    tex = {"cobblestone.png"},
  },
  [4] = {
    id = 4,
    name = "wall",
    tex = {"wall.png"},
    collision = true,
  },
  [5] = {
    id = 5,
    name = "desk",
    tex = {"desk.png"},
    collision = true,
  },
  [6] = {
    id = 6,
    name = "manhole",
    tex = {"manhole.png"},
  },
  [7] = {
    id = 7,
    name = "laser_horizontal",
    tex = {"laser_horizontal_1.png", "laser_horizontal_2.png"},
    texRefresh = 500,
    collision = true,
  },
  [8] = {
    id = 8,
    name = "laser_vertical",
    tex = {"laser_vertical_1.png", "laser_vertical_2.png"},
    texRefresh = 500,
    collision = true,
  },
  [9] = {
    id = 9,
    name = "cobweb",
    tex = {"cobweb.png"},
  },
  [10] = {
    id = 10,
    name = "roof",
    tex = {"roof.png"},
  },
  [11] = {
    id = 11,
    name = "dirty_cobblestone",
    tex = {"cobblestone_dirty.png"},
  },
  [12] = {
    id = 12,
    name = "dirt",
    tex = {"dirt.png"},
  },
}

for id, block in pairs(blocks) do
  for tid, tex in pairs(block.tex) do
    blocks[id].tex[tid] = love.graphics.newImage("assets/img/blocks/" .. tex)
  end
  blocks[id].currentTex = 1
  if #blocks[id].tex > 1 then
    blocks[id].texTimer = setTimer(function(block)
      if block.currentTex >= #block.tex then
        block.currentTex = 1
      else
        block.currentTex = block.currentTex + 1
      end
    end, blocks[id].texRefresh, 0, blocks[id])
  end
end

createMap = function(arg)
  local map = createElement("map", arg)

  if not map._blocks then map._blocks = {} end
  if not map.blocks then map.blocks = {} end

  map.createBlock = function(self, x, y, id)
    local isBlockExist = false
    if not self._blocks then self._blocks = {} end
    if not self.blocks then self.blocks = {} end
    for i, block in pairs(self.blocks) do
      if block.position.x == x and block.position.y == y then
        isBlockExist = true
        self.blocks[i] = nil
      end
    end
    local block = {position = {x = x, y = y}, id = id}
    table.insert(self.blocks, block)
    if not self._blocks[x] then self._blocks[x] = {} end
    self._blocks[x][y] = block
  end

  map.destroyBlock = function(self, x, y)
    for i, block in pairs(self.blocks) do
      if block.position.x == x and block.position.y == y then
        self.blocks[i] = nil
        if self._blocks[x] then self._blocks[x][y] = nil end
        return true
      end
    end
    return false
  end

  map.load = function(self, mapname)
    if not love.filesystem.getInfo("assets/maps/" .. mapname .. ".json") then
      return false
    end
    local contents, size = love.filesystem.read("assets/maps/" .. mapname .. ".json", 1024 * 1024)
    local mapContent = json.parse(contents)
    if not mapContent then
      outputDebug("map.load - nie mozna odczytac mapy przez zly zapis JSON", {255, 0, 0})
      return false
    end
    self.blocks = nil
    self._blocks = nil
    for _, block in pairs(mapContent) do
      self:createBlock(block.position.x, block.position.y, block.id)
    end
    return true
  end

  return map
end

local createdMap = {}
local mapEditor

function mapKeyPressed(key)
  if key == "m" and love.keyboard.isDown("lctrl") and developer then
    mapCreator = not mapCreator
    if mapCreator then
      mapEditor = createMap({render = true})
      
      if love.filesystem.getInfo("assets/maps/mapEditor.json") then
        mapEditor:load("mapEditor")
      end
    else
      mapEditor:destroy()
    end
  elseif developer and mapCreator then
    local cb = getCurrentBlock()
    
    if not cb then
      x, y = math.ceil(localPlayer.position.x - 0.5), math.ceil(localPlayer.position.y - 0.5)
    else
      x, y = cb.position.x, cb.position.y
    end
    if key == "s" and love.keyboard.isDown("lctrl") then
      local jsonData = json.stringify(mapEditor.blocks)
      local success, message = love.filesystem.write("mapEditor.json", jsonData, string.len(jsonData))
      if success then
        outputDebug("Zapisano mape pomyslnie", {0, 220, 30})
      else
        outputDebug("Nie mozna zapisac mapy (" .. message .. ")", {240, 2, 10})
      end
    elseif key == "1" then
      mapEditor:createBlock(x, y, 1)
    elseif key == "2" then
      mapEditor:createBlock(x, y, 2)
    elseif key == "3" then
      mapEditor:createBlock(x, y, 3)
    elseif key == "4" then
      mapEditor:createBlock(x, y, 4)
    elseif key == "5" then
      mapEditor:createBlock(x, y, 5)
    elseif key == "6" then
      mapEditor:createBlock(x, y, 6)
    elseif key == "7" then
      mapEditor:createBlock(x, y, 7)
    elseif key == "8" then
      mapEditor:createBlock(x, y, 8)
    elseif key == "9" then
      mapEditor:createBlock(x, y, 9)
    elseif key == "0" then
      mapEditor:createBlock(x, y, 10)
    elseif key == "-" then
      mapEditor:createBlock(x, y, 11)
    elseif key == "=" then
      mapEditor:createBlock(x, y, 12)
    elseif key == "delete" then
      mapEditor:destroyBlock(x, y)
    end
  end
end

function getAllBlocksFromRenderingMaps(distance)
  local bl = {}
  if not localPlayer then return end
  if not distance then
    for _, map in pairs(getElementsByType("map")) do
      if map.render then
        for _, block in pairs(map.blocks) do
          if not bl[block.position.x] then bl[block.position.x] = {} end
          bl[block.position.x][block.position.y] = block
        end
      end
    end
  else
    local px, py = math.ceil(localPlayer.position.x), math.ceil(localPlayer.position.y)
    for _, map in pairs(getElementsByType("map")) do
      for x = px - distance, px + distance do
        for y = py - distance, py + distance do
          if map._blocks[x] and map._blocks[x][y] then
            if not bl[x] then bl[x] = {} end
            bl[x][y] = map._blocks[x][y]
          end 
        end    
      end
    end
  end
  return bl
end

function getBlocksNearPlayer() -- Nie skonczone
  local bl = getAllBlocksFromRenderingMaps(3)
  local x, y = localPlayer.position.x, localPlayer.position.y
  local ceilX, ceilY = math.ceil(localPlayer.position.x), math.ceil(localPlayer.position.y)
  local floorX, floorY = math.floor(localPlayer.position.x), math.floor(localPlayer.position.y)

  local fromToX = {0, 0}
  local fromToY = {0, 0}

  if isInteger(x) then
    fromToX = {}
  end
end

function getBlock(bl, x, y)
  if bl[x] and bl[x][y] then return bl[x][y] else return false end
end

function getCurrentBlock()
  local bl = getAllBlocksFromRenderingMaps(1)
  if not localPlayer then return false end
  local x, y = math.ceil(localPlayer.position.x - 0.5), math.ceil(localPlayer.position.y - 0.5)
  return getBlock(bl, x, y)
end

function isNearCollision(from)
  local x, y = localPlayer.position.x - 1 / pedSize, localPlayer.position.y - 1 / pedSize

  local ceilX, ceilY = math.ceil(localPlayer.position.x), math.ceil(localPlayer.position.y)
  local floorX, floorY = math.floor(localPlayer.position.x), math.floor(localPlayer.position.y)
  local bl = getAllBlocksFromRenderingMaps(1)

  if from == "right" then
    local currentBlock = getBlock(bl, ceilX, ceilY - 1)
    local currentBlock2 = getBlock(bl, ceilX, ceilY)
    if currentBlock and currentBlock2 and (blocks[currentBlock.id].collision or blocks[currentBlock2.id].collision) then -- Jeśli są 2 bloki i jeden z nich ma kolizję
      return true
    elseif not currentBlock or not currentBlock2 then -- Jeśli jeden z bloków obok nie istnieje to się zatrzymaj
      return true
    else
      return false
    end

  elseif from == "left" then
    local currentBlock = getBlock(bl, ceilX - 1, ceilY - 1)
    local currentBlock2 = getBlock(bl, ceilX - 1, ceilY)
    if currentBlock and currentBlock2 and (blocks[currentBlock.id].collision or blocks[currentBlock2.id].collision) then -- Jeśli są 2 bloki i jeden z nich ma kolizję
      return true
    elseif not currentBlock or not currentBlock2 then -- Jeśli jeden z bloków obok nie istnieje to się zatrzymaj
      return true
    else
      return false
    end

  elseif from == "up" then
    local currentBlock = getBlock(bl, ceilX - 1, ceilY - 1)
    local currentBlock2 = getBlock(bl, ceilX, ceilY - 1)
    if currentBlock and currentBlock2 and (blocks[currentBlock.id].collision or blocks[currentBlock2.id].collision) then
      return true
    elseif not currentBlock or not currentBlock2 then
      return true
    else
      return false
    end

  elseif from == "down" then
    local currentBlock = getBlock(bl, ceilX -1, ceilY)
    local currentBlock2 = getBlock(bl, ceilX, ceilY)
    if currentBlock and currentBlock2 and (blocks[currentBlock.id].collision or blocks[currentBlock2.id].collision) then
      return true
    elseif not currentBlock or not currentBlock2 then
      return true
    else
      return false
    end
  end
  return false
end

local background = love.graphics.newImage("assets/img/background.png")

function renderMap()
  love.graphics.draw(background, 0, 0, 0, sw / background:getWidth(), sh / background:getHeight())
  for i, map in pairs(getElementsByType("map")) do
    if map.render then
      if localPlayer then
        local px, py = localPlayer.position.x, localPlayer.position.y
        
        local fromToX = {math.ceil(px - settings.renderDistance - 0.5), math.ceil(px + settings.renderDistance - 0.5)}
        local fromToY = {math.ceil(py - settings.renderDistance - 0.5), math.ceil(py + settings.renderDistance - 0.5)}

        for x = fromToX[1], fromToX[2] do
          for y = fromToY[1], fromToY[2] do
            if map._blocks[x] and map._blocks[x][y] then
              local block = map._blocks[x][y]

              
              local tex = blocks[block.id].tex[blocks[block.id].currentTex]
              local bS = (blockSize * gameSize)
              local dx = sw / 2 - bS / 2 - (px - 1) * bS + (x - 1) * bS;
              local dy = sh / 2 - bS / 2 - (py - 1) * bS + (y - 1) * bS;
              
              love.graphics.draw(tex, dx, dy, 0, bS / tex:getWidth(), bS / tex:getHeight())
            end
          end
        end
      end
    end
    if mapCreator then
      gui.drawText("Tworzenie mapy wlaczone...", 0, 0, sw, sh, gui.getFont(nil, 22), "right")
    end
  end
end