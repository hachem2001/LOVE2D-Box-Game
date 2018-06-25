local maploader = {}

function maploader.loadmap(filepath)
	local map = love.filesystem.load(filepath)()
	
	local tilesets = {}	-- To store the tilesets
	local layers = {} -- To store the quads
	local spawn_points = {} -- To store the spawn points
	local prev_start_count = 0

	for k, tileset in pairs(map.tilesets) do
		local quads = {} -- to store the quads
		local tile_set_name = tileset.name;
		local tileset_image = love.graphics.newImage("images/"..tileset.image);
		tileset_image:setFilter("nearest");
		local tile_w, tile_h = tileset.grid.width, tileset.grid.height;
		local image_width = tileset_image:getWidth();
		local image_height = tileset_image:getHeight();
		
		local gridw, gridh = image_width/tile_w,image_height/tile_h;
		for y=1,gridh do
			for x=1,gridw do
				quads[x+(y-1)*gridw] = love.graphics.newQuad((x-1)*tile_w, (y-1)*tile_h, tile_w, tile_h, image_width, image_height);
			end
		end
		tilesets[k] = {quads = quads, name = tile_set_name, image = tileset_image, tw = tile_w, th = tile_h, image_w = image_width, image_h = image_height, start_count = prev_start_count + 1, end_count = prev_start_count + tileset.tilecount }
		prev_start_count = prev_start_count + tileset.tilecount;
	end
	
	for k,v in pairs(map.layers) do
		if v.type == "tilelayer" then
			local offsetx = v.offsetx;
			local offsety = v.offsety;
			
			local layerwidth = v.width;
			local layerheight = v.height;
			
			local properties = v.properties;
			local sprite_batches = {};
			
			local grid = {};
			
			for x=0,layerwidth-1 do
				grid[x] = {}
				for y=0,layerheight-1 do
					grid[x][y] = 0;
				end
			end
			
			local datasize = #v.data
			
			for m=0, datasize-1 do
				local x = m%layerwidth
				local y = math.floor(m/layerwidth)
				
				local data_value = v.data[m+1];
				
				grid[x][y] = data_value;
				if not (data_value<=0) then
					for k2,v2 in pairs(tilesets) do
						if data_value>=v2.start_count and data_value <= v2.end_count then
							if not sprite_batches[k2] then sprite_batches[k2] = love.graphics.newSpriteBatch(v2.image) end
							sprite_batches[k2]:add(v2.quads[data_value-v2.start_count+1], x*v2.tw, y*v2.th);
						end
					end
				end
			end
			layers[#layers+1] = {offsetx = offsetx, offsety = offsety, width = layerwidth, height = layerheight, properties = properties, 
				grid = grid,sprite_batches = sprite_batches};
		elseif v.type=="objectgroup" then
			if v.name:lower():match("spawn") then
				for k2, _spawn_point in pairs(v.objects) do
					spawn_points[#spawn_points+1] = {type = _spawn_point.type, x = _spawn_point.x, y = _spawn_point.y, properties = _spawn_point.properties}
				end
			end
		end
	end
	local to_return_map = {tilesets = tilesets, layers = layers, spawn_points = spawn_points,
		w=map.width, h=map.height, tw=map.tilewidth, th=map.tileheight}
	return to_return_map;
end

return maploader