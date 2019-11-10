
local screenX, screenY = love.graphics.getWidth(), love.graphics.getHeight()
local bgr = love.graphics.newImage("assets/img/background.png")
local bgrX, bgrY = bgr:getWidth(), bgr:getHeight()

local menu = {
  [1] = {
    text = "Play",
    func = function()
        gameState = "play"
        destroyMenu()
    end,
  },
  [2] = {
    text = "Exit",
    func = function()
      love.event.quit()
    end,
  }
}

local actuallyIndexMain = 1
renderMenu = function()
  love.graphics.draw(bgr, 0, 0, 0, screenX / bgrX, screenY / bgrY)
  gui.drawText("Prison Escape\n" .. version, 0, 50, screenX, screenY, gui.getFont(nil, 18), "center", "top")
  for k,v in pairs(menu) do
    local offsetY = k * 40
    gui.drawText(k == actuallyIndexMain and "-" .. v.text .. "-" or v.text, screenX / 2, offsetY / 2 - 18 * #menu, 0, screenY, gui.getFont(nil, 18), "center", "center")
  end
end

destroyMenu = function()
  screenX, screenY, actuallyIndexMain, menu, bgr, bgrX, bgrY = nil, nil, nil, nil, nil, nil
  collectgarbage("collect")
end

moveMenuComponents = function(isDown)
  if isDown == "up" then
    actuallyIndexMain = actuallyIndexMain > 1 and actuallyIndexMain - 1 or actuallyIndexMain
  elseif isDown == "down" then
    actuallyIndexMain = actuallyIndexMain < #menu and actuallyIndexMain + 1 or actuallyIndexMain
  elseif isDown == "return" then
    menu[actuallyIndexMain].func()
  end
end
