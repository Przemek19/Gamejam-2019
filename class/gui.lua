gui = {}
gui.fonts = {}
local defaultFont = "OpenSans"

gui.getFont = function(name, size)
  if not name then name = defaultFont end
  if not size or not tonumber(size) then size = 18 end
  if not gui.fonts[name] then gui.fonts[name] = {} end
  if not gui.fonts[name][size] then gui.fonts[name][size] = love.graphics.newFont("assets/fonts/" .. name .. ".ttf", size) end
  return gui.fonts[name][size]
end

gui.drawText = function(text, x, y, width, height, font, horizontal, vertical)
  if not tostring(text) then outputDebug("gui.drawText - brak tekstu!", {255, 0, 0}) return end
  if not font then outputDebug("gui.drawText - brak czcionki!", {255, 0, 0}) return end

  love.graphics.setFont(font)

  if not x then x = 0 end
  if not y then y = 0 end
  if not width then width = 0 end
  if not height then height = 0 end

  local fw = font:getWidth(text)
  local fh = font:getHeight(text)
  if not vertical then vertical = "top" end
  if not horizontal then horizontal = "left" end

  local xPos = x;
  local yPos = y;

  --g.rectangle("fill", x, y, width, height);

  if horizontal == "center" then
    xPos = x + width / 2 - fw / 2
  elseif horizontal == "right" then
    xPos = x + width - fw
  end

  if vertical == "center" then
    yPos = y + height / 2 - fh / 2
  elseif vertical == "bottom" then
    yPos = y + height - fh
  end

  love.graphics.print(text, xPos, yPos)

  love.graphics.reset()
end

gui.isCursorInPosition = function(x, y, width, height)
  local cx, cy = love.mouse.getPosition()
  return (cx >= x and x + width >= cx) and (cy >= y and y + height >= cy)
end