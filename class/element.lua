root = {}
root.elements = {}

local lastID = 0
createElement = function(type, arg)
  if not tostring(type) then outputDebug("createElement - Błędny typ", {255, 0, 0}) return false end
  lastID = lastID + 1
  local element = {
    id = lastID,
    type = type,
  }
  element.destroy = function(self)
    for i, el in pairs(root.elements) do
      if self == el then
        root.elements[i] = nil
      end
    end
  end
  if arg then
    for i, v in pairs(arg) do
      element[i] = v
    end
  end
  root.elements[lastID] = element

  return root.elements[lastID]
end

getElementByID = function(id)
  if not tonumber(id) then outputDebug("getElementByID - Brak id", {255, 0, 0}) return false end
  for _, element in pairs(root.elements) do
    if element.id == id then
      return element
    end
  end
  return false
end

getElementsByType = function(type)
  if not tostring(type) then outputDebug("getElementsByType - Błędny typ", {255, 0, 0}) return false end
  local elements = {}
  for _, element in pairs(root.elements) do
    if element.type == type then
      table.insert(elements, element)
    end
  end
  return elements
end