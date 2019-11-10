local messages = {}
local messagesCount = 8

local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
local font = love.graphics.newFont(20)

outputDebug = function(message, color)
  if not color then color = {255, 255, 255, 255} end
  if not color[4] then color[4] = 255 end
  color = {color[1] / 255, color[2] / 255, color[3] / 255, color[4] / 255}
  table.insert(messages, {m = tostring(message), c = color})
end

drawDebug = function()
  local j = 0
  love.graphics.print("FPS: " .. love.timer.getFPS() .. "\nPos:\nx = " .. localPlayer.position.x .. "\n y = " .. localPlayer.position.y)
  for i = #messages - messagesCount, #messages do
    local msg = messages[i]
    if msg then
      j = j + 1
      love.graphics.setColor({0, 0, 0, 0.7})
      love.graphics.print(msg.m, 7, sh - j * 22 - 1)
      love.graphics.setColor(msg.c)
      love.graphics.print(msg.m, 8, sh - j * 22)
      love.graphics.reset()
    end
  end
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", sw / 2 - 1, sh / 2 - 1, 2, 2)
  love.graphics.reset()
end