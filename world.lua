local maploader = maploader or require "maploader"
local world = {}
world.map = {}

function world:setmap(filepath)
	local map = maploader.loadmap(filepath)
	self.map = map;
end

function world:draw()
	for layer=1,#self.map.layers do
		local curlayer = self.map.layers[layer];
		for k, spritebatch in pairs(curlayer.sprite_batches) do
			love.graphics.draw(spritebatch);
		end
	end
end

return world;