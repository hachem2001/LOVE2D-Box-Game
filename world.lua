local maploader = maploader or error("Map loader not loaded before use of world class");
local world = {}
world.map = {}
world.collision_tiles = {}

function world:setmap(filepath)
	local map = maploader.loadmap(filepath);
	self.map = map;
	for k,v in pairs(self.map.layers) do
		if v.properties.collision == true then
			for x = 0, self.map.w-1 do -- map.w is the width of the map
				for y=0,self.map.h-1 do
					local m = v.grid[x][y]
					if m~=0 then
						self.collision_tiles[#self.collision_tiles+1] = {grid_x=x, grid_y=y, x=x*self.map.tw, y=y*self.map.th}; -- The tile width and height are ommitted because they're already saved in the map.
					end
				end
			end
		end
	end
	entmanager:new("player", self.map.spawn_points[1])
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
		if dx < tw and dx > -w and dy < th and dy > -h then
			print("COLLISION")
			local depthx, depthy = 0,0;
			if math.abs(dx-tw)>math.abs(dx+w) then
				depthx = dx+w;
			else
				depthx = dx-tw;
			end
			if math.abs(dy-th)>math.abs(dy+h) then
				depthy = dy+h;
			else
				depthy = dy-th;
			end
			if math.abs(depthx)>math.abs(depthy) then
				depthx = 0;
			else
				depthy = 0;
			end
			obj.x = obj.x - depthx;
			obj.y = obj.y - depthy;
			return true, k, depthx, depthy -- collision happens? return the index of the collision tile, and the depth of the collision
		end
	end
	return false -- no collision? return false.
end

return world;