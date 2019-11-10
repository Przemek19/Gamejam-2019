createPed = function(arg)
	local ped = createElement("ped", arg)
	if arg and type(arg) == "table" then
		ped.position = arg and arg.position or {x = 0, y = 0}
		ped.tex = arg.tex or {love.graphics.newImage("assets/img/player_1.png"), love.graphics.newImage("assets/img/player_2.png")}
		ped.speed = arg.speed or 1
	end
	ped.setTextures = function(self, t1, t2)
		self.tex = {love.graphics.newImage("assets/img/" .. t1 .. ".png"), love.graphics.newImage("assets/img/" .. t2 .. ".png")}
	end
	return ped
end

local sw, sh = love.graphics.getWidth(), love.graphics.getHeight()
local fog = love.graphics.newImage("assets/img/inner_shadow.png")

local getDistanceBetweenTwoPoints = function(x2, x1, y2, y1)
	return math.sqrt((math.abs(x2 - x1))^2 + (math.abs(y2 - y1))^2)
end

function isPedOnMap(ped)
	for i, map in pairs(getElementsByType("map")) do
		if map.render and ped.map == map then
			return true
		end
	end
	return false
end

renderPeds = function()
	if not localPlayer then return end
	local x, y = localPlayer.position.x, localPlayer.position.y
	for _, ped in pairs(getElementsByType("ped")) do
		if ped ~= localPlayer then
			local tex = ped.tex[1]
			local pS = (pedSize * gameSize)
			local bS = (blockSize * gameSize)

			if isPedOnMap(ped) and settings.renderDistance > (math.abs(ped.position.x - localPlayer.position.x) - 0.5) and settings.renderDistance > (math.abs(ped.position.y - localPlayer.position.y) - 0.5) then
				local dx, dy = sw / 2 - pS / 2 + (ped.position.x - localPlayer.position.x) * bS, sh / 2 - pS / 2 + (ped.position.y - localPlayer.position.y) * bS
				love.graphics.draw(tex, dx, dy, 0, pS / tex:getWidth(), pS / tex:getHeight())
			end
		end
	end

	local tex = localPlayer.tex[1]
	if (love.keyboard.isDown("up") or love.keyboard.isDown("down") or love.keyboard.isDown("left") or love.keyboard.isDown("right")) then
		if getTickCount() % 200 > 100 then
			tex = localPlayer.tex[1]
		else
			tex = localPlayer.tex[2]
		end
	end

	love.graphics.draw(tex, sw / 2 - (pedSize * gameSize) / 2, sh / 2 - (pedSize * gameSize) / 2, 0, (pedSize * gameSize) / tex:getWidth(), (pedSize * gameSize) / tex:getHeight())
	love.graphics.draw(fog, 0, 0, 0, sw / fog:getWidth(), sh / fog:getHeight())
end

pedMousepressed = function(x, y, button)
	if button ~= 1 then return end

	local pS = (pedSize * gameSize)
	local bS = (blockSize * gameSize)

	for i, ped in pairs(getElementsByType("ped")) do
		if settings.renderDistance > (math.abs(ped.position.x - localPlayer.position.x) - 0.5) and settings.renderDistance > (math.abs(ped.position.y - localPlayer.position.y) - 0.5) then
			local dx, dy, width, height = sw / 2 - pS / 2 + (ped.position.x - localPlayer.position.x) * bS, sh / 2 - pS / 2 + (ped.position.y - localPlayer.position.y) * bS, pS, pS
			local ceilX, ceilY = math.ceil(localPlayer.position.x - 0.5), math.ceil(localPlayer.position.y - 0.5)
			local bl = getAllBlocksFromRenderingMaps(1)

			for i, b in pairs(bl) do
				if gui.isCursorInPosition(dx, dy, width, height) then
					if ped.func then ped.func() end
					break
				end			
			end
		end
	end

end