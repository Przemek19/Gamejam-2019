local screenX, screenY = love.graphics.getWidth(), love.graphics.getHeight()

local messages, messageIndex, messagesState = {}, 1, false

newDialogue = function(texts, func)
  if not messagesState and #texts < 1 then return end
  table.insert(messages, texts)
  messagesState = true
  localPlayer.disabled = true
end

renderDialogue = function()
  if not messagesState then return end
  love.graphics.setColor(0.2, 0.2, 0.2, 0.85)
  love.graphics.rectangle("fill", 0, screenY - 100, screenX, 100)
  love.graphics.reset()
  gui.drawText(messages[1][messageIndex].speaker .. ": " .. messages[1][messageIndex].text, 0, screenY - 100, screenX, 100, gui.getFont(nil, 18), "center", "center")
end

moveDialogueMessage = function(isDown)
  if messagesState and isDown == "space" then
    if messageIndex < #messages[1] then
      messageIndex = messageIndex + 1
    else
      if messages[1][messageIndex].func then
        messages[1][messageIndex].func()
      end
      messagesState, messageIndex = false, 1
      localPlayer.disabled = nil
      for i = 1, #messages[1] do
        table.remove(messages, i)
      end
    end
  end
end
