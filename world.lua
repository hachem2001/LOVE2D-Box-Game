local maploader = maploader or require "maploader"
local world = {}
world.map = {}
world.collision_tiles = {}

function world:setmap(filepath)
	local map = maploader.loadmap(filepath);
	self.map = map;
	for k,v in pairs(self.map.layers) do
		if v.properties.collision == true then
			for x = 1, self.map.w do -- map.w is the width of the map
				for y=1,self.map.h do
					local m = v.grid[x][y]
					if m~=0 then
						self.collision_tiles[#self.collision_tiles+1] = {grid_x=x, grid_y=y, x=(x-1)*self.map.tw, y=(y-1)*self.map.th}; -- The tile width and height are ommitted because they're already saved in the map.
					end
				end
			end
		end
	end
end

function world:draw()
	for layer=1,#self.map.layers do
		local curlayer = self.map.layers[layer];
		for k, spritebatch in pairs(curlayer.sprite_batches) do
			love.graphics.draw(spritebatch);
		end
	end
end

function world:collide(obj) -- AABB collision, returns how much to go out in X and Y
	local x, y, w, h = obj.x, obj.y, obj.w, obj.h;
	local tw, th = self.map.tw, self.map.th;
	for k,v in pairs(self.collision_tiles) do
		local dx = x-v.x;
		local dy = y-v.y;
		if dx < tw and dx > -w and dy < ty  and dy > tx then
			local depthx, depthy = 0,0;
			if math.abs(dx-tw)>math.abs(dx+w) then
				depthx = w;
			else
				depthx = -tw;
			end
			if math.abs(dy-th)>math.abs(dy+h) then
				depthy = h;
			else
				depthy = -th;
			end
			obj.x = obj.x - depthx;
			obj.y = obj.y - depthy;
			x = obj.x;
			y = obj.y;
			return true, k, depthx, depthy -- collision happens? return the index of the collision tile, and the depth of the collision
		end
	end
	return false -- no collision? return false.
end

return world;