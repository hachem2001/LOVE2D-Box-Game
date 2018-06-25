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

function world:draw_background()
	love.graphics.push()

	love.graphics.setColor(1,1,1,1)
	for layer=1,#self.map.layers do
		local curlayer = self.map.layers[layer];
		if not curlayer.properties.foreground and not curlayer.properties.transparent then
			for k, spritebatch in pairs(curlayer.sprite_batches) do
				love.graphics.draw(spritebatch);
			end
		end
	end

	love.graphics.pop()
end

function world:draw_foreground()
	love.graphics.push()

	love.graphics.setColor(1,1,1,1)
	for layer=1,#self.map.layers do
		local curlayer = self.map.layers[layer];
		if curlayer.properties.foreground and not curlayer.properties.transparent then
			for k, spritebatch in pairs(curlayer.sprite_batches) do
				love.graphics.draw(spritebatch);
			end
		end
	end

	love.graphics.pop()
end

function world:collide(obj, to_addx, to_addy) -- AABB collision, returns how much to go out in X and Y
	local x, y, w, h = obj.x, obj.y, obj.w, obj.h;
	local nx, ny = x+to_addx, y+to_addy;
	local tw, th = self.map.tw, self.map.th;
	local X_COLL = false;
	local Y_COLL = false;
	for k,v in pairs(self.collision_tiles) do
		X_COLL = X_COLL or self.coll(nx, y, w, h, v.x, v.y, tw, th);
		Y_COLL = Y_COLL or self.coll(x, ny, w, h, v.x, v.y, tw, th);
		if X_COLL and Y_COLL then
			return X_COLL, Y_COLL;
		end
	end
	return X_COLL, Y_COLL; -- no collision? return false.
end

function world.coll(x, y, w, h, x2, y2, h2, w2)
	local dx = x-x2;
	local dy = y-y2;
	if (dx>=-w and dx<=w2 and dy>=-h and dy<=h2) then
		return true
	end
	return false
end

return world;