local c = {
  "debug", "useful", "element", "gui", "menu", "ped", "map", "dialogoues",
}

socket = require("socket")

json = require("class/json")

for i, v in pairs(c) do
  require("class/" .. v)
end