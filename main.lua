--[[
  TODO:
  - interfejs menu - zrobione
  - markery
  - kreator map - zrobione

]]--

developer = false
version = "Pre-Alpha 0.1"

love.window.setMode(1920, 1080, {vsync = true, fullscreen = true})
sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
gameState = "menu" -- "menu", "play"

require("composer")

localPlayer = createPed({position = {x = 0, y = 0}, name = "Tim Robbins"})
localPlayer.speed = 2
settings = {
  renderDistance = 8,
}

outputDebug("Debug on...", {0, 40, 240})

function love.draw()
  --love.graphics.print(123)
  if gameState == "menu" then -- render menu interface when not disabled
    renderMenu()
  elseif gameState == "play" then -- render all interface when the menu is disabled
    renderMap()
    renderPeds()
    renderDialogue()
  end
  if developer then drawDebug() end
end

gameSize = 1 -- 1 do 4
blockSize = 64
pedSize = blockSize

function love.wheelmoved(x, y)
  gameSize = math.min(math.max(gameSize + y / 10, 1), 4) -- od 1 do 4
end

function love.keypressed(isDown)
  if gameState == "menu" then
    moveMenuComponents(isDown)
  elseif gameState == "play" then
    moveDialogueMessage(isDown)
  end
  if isDown == "escape" then
    love.event.quit()
  end
  mapKeyPressed(isDown)
end

isPlayerInPosition = function(x, y)
  if not localPlayer then return false end
  return math.ceil(localPlayer.position.x - 0.5) == x and math.ceil(localPlayer.position.y - 0.5) == y
end

moveTimer = setTimer(function()
  if localPlayer.disabled then return end
  if gameState == "play" then 
    local spd = localPlayer.speed * (mapCreator and 3 or 1)
    if love.keyboard.isDown("left") and love.keyboard.isDown("up") or love.keyboard.isDown("left") and love.keyboard.isDown("down") or love.keyboard.isDown("right") and love.keyboard.isDown("up") or love.keyboard.isDown("right") and love.keyboard.isDown("down") then  
      spd = spd / math.sqrt(2)
    end
    if love.keyboard.isDown("left") then
      if not isNearCollision("left") or mapCreator then
        localPlayer.position.x = localPlayer.position.x - (spd / pedSize)
      end
    elseif love.keyboard.isDown("right") then
      if not isNearCollision("right") or mapCreator then
        localPlayer.position.x = localPlayer.position.x + (spd / pedSize)
      end
    end
    if love.keyboard.isDown("up") then
      if not isNearCollision("up") or mapCreator then
        localPlayer.position.y = localPlayer.position.y - (spd / pedSize)
      end
    elseif love.keyboard.isDown("down") then
      if not isNearCollision("down") or mapCreator then
        localPlayer.position.y = localPlayer.position.y + (spd / pedSize)
      end
    end
  end
end, 4, 0)

function love.update()
  updateTimers()
end

function love.mousepressed(x, y, button, istouch, presses)
  if key == 3 then
    gameSize = 1
  end
  pedMousepressed(x, y, button)
end




------------------------
-- ROZPOCZĘCIE FABUŁY --
------------------------

map = createMap({render = true})
map:load("prison1")

newDialogue({
  {speaker = "Samouczek", text = 'Aby przewijać dialog klknij "space"'},
  {speaker = "Samouczek", text = "Aby poruszyć postacią używaj strzałek"},
  {speaker = "Samouczek", text = "Aby wejść w interakcje z otoczeniem kliknij lpm w obiekt"},
  {speaker = "Samouczek", text = "Powodzenia :)"},
})

local list1 = createPed({position = {x = 1, y = 1}})
list1.func = function()
  newDialogue({
    {speaker = "List", text = "Idź w stronę północy...", func = function()
      list1:destroy()
    end},
  })
end
list1.map = map
list1.tex = {love.graphics.newImage("assets/img/list.png")}

local isHaveKey = {
  [1] = false,
}

local lock1 = createPed({position = {x = - 12, y = 0}})
lock1.tex = {love.graphics.newImage("assets/img/blocks/lock.png")}
lock1.map = map
lock1.func = function()
  if isHaveKey[1] then
    map:destroyBlock(-12, -1)
    map:destroyBlock(-12, 0)
    map:destroyBlock(-12, 1)
    map:createBlock(-12, -1, 3)
    map:createBlock(-12, 0, 3)
    map:createBlock(-12, 1, 3)
    
    newDialogue({{speaker = localPlayer.name, text = "Udało mi się! A co tam jest? Czyżby studzienka kanalizacyjna?"}})
    lock1:destroy()

    lock2 = createPed({position = {x = -18, y = 0}})
    lock2.tex = {love.graphics.newImage("assets/img/blocks/lock.png")}
    lock2.map = map

    lock2.func = function()
      map:destroy()
      kanaly = createMap({render = true})
      kanaly:load("kanaly")
      settings.renderDistance = 1
      newDialogue({{speaker = localPlayer.name, text = "Ale tu ciemno! Muszę znaleźć wyjście"}})
      localPlayer.position = {x = -1.5, y = -1.5}
      key3 = createPed({position = {x = -20, y = 7}})
      key3.tex = {love.graphics.newImage("assets/img/key.png")}
      key3.map = kanaly
      key3.func = function()
        isHaveKey[3] = true
        key3:destroy()
        newDialogue({{speaker = localPlayer.name, text = "Znalazłem klucz do otwarcia studzienki! Teraz trzeba ją tylko znaleźć..."}})
      end

      lock3 = createPed({position = {x = -16, y = 19}})
      lock3.tex = {love.graphics.newImage("assets/img/blocks/lock.png")}
      lock3.map = kanaly
      lock3.func = function()
        if isHaveKey[3] then
          settings.renderDistance = 8
          newDialogue({
            {speaker = localPlayer.name, text = "Udało się! Jestem wolny!"},
            {speaker = "", text = "Gratulacje, jesteś na wolności!"},
            {speaker = "", text = "Jest to pierwszy nasz prototyp gry w prostym silniku opartym o język Lua."},
            {speaker = "", text = "Dziekujemy za poświęcony czas :D."},
          })
          kanaly:destroy()
          ground = createMap({render = true})
          ground:load("ground")
          localPlayer.position = {x = 0, y = 2}

        else
          newDialogue({{speaker = localPlayer.name, text = "Wygląda na to, że nie mam klucza. Musi gdzieś tu być!"}})
        end
      end
    end

  else
    newDialogue({{speaker = localPlayer.name, text = "Hmm, ręką tego nie otworzę..."}})
  end
end

local policeman1 = createPed({position = {x = -17, y = -14}})
policeman1.func = function()
  newDialogue({
    {speaker = "Policjant", text = "Czego tu szukasz?"},
    {speaker = localPlayer.name, text = "Nieważne..."},
    {speaker = "Policjant", text = "Obym Cię tu więcej nie widział!"},
    {speaker = "Narrator", text = "(( Policjant odszedł, jednak wypadł mu klucz. Ciekawe do, której celi... ))", func = function()
      policeman1:destroy()
      
      local klucz1 = createPed({position = {x = -17, y = -14}})
      klucz1.tex = {love.graphics.newImage("assets/img/key.png")}
      klucz1.map = map
      klucz1.func = function()
        newDialogue({{speaker = localPlayer.name, text = "Podniosłem klucz! Idę szukać wyjścia!"}})
        isHaveKey[1] = true
        klucz1:destroy()
      end

    end},
  })
end
policeman1.map = map
policeman1.tex = {love.graphics.newImage("assets/img/policeman.png")}
