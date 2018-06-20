local entmanager = {}
---------------
-----SETUP--------------------------------------------------------------------------------------------------------------------------
---------------
-- ENTS STUFF
entmanager.ref = "entities/" -- entities location
entmanager.entnames = {
	base = "base.lua",
	player = "player.lua",
}
entmanager.loadedents	={}
entmanager.ents 			={}
--


-- IDS STUFF
entmanager.innerids={}
--


-- QUEUE STUFF
entmanager.todo = {}
--
---------------
------END------
---------------


---------------
-- Functions -----------------------------------------------------------------------------------------------------------------------
---------------

-- Ent stuff
function entmanager:load()
	for k,v in pairs(self.entnames) do
		self.loadedents[k] = love.filesystem.load(self.ref..v) -- save load the entities ( probably more efficient than requiring them each time )
		self.innerids[k] = 0
	end
end

function entmanager:rawnew(typ, ...) -- make an non indexed entity ( thus the name "raw" )
	local args = {...}
	local ent = self.loadedents[typ]() -- loads the entity
	ent:setinfo(unpack(args))
	return ent
end

function entmanager:new(typ, ...) -- make a new indexed entity
	local args = {...}
	self.ents[#self.ents+1] = self.loadedents[typ]()
	self.ents[#self.ents].generalid = #self.ents
	self.ents[#self.ents]:setinfo(unpack(args))
	return #self.ents
end

function entmanager:remove_entity(id)
	table.remove(self.ents, id)
end

-- Action stuff
function entmanager:add_todo(delay, action, info) -- Queue an action
	self.todo[#self.todo+1] = {time=love.timer.getTime(), delay=delay, action=action, info=info}
end

function entmanager:remove_todo(num) -- remove that action
	table.remove(self.todo, num)
end

---------------
------END------
---------------



---------------
-----EVENTS-------------------------------------------------------------------------------------------------------------------------
---------------
function entmanager:draw() -- Draw all entities ( that are drawable of course )
	love.graphics.push()
		for k,v in pairs(self.ents) do
			v:draw()
		end
	love.graphics.pop()
end

function entmanager:update(dt) -- Update all entities
	for k,v in pairs(self.ents) do
		v:update(dt)
	end
end

function entmanager:keypressed(const ,scancode) -- Key pressed event
	for k,v in pairs(self.ents) do
		if v.eventsneeded.keypressed then
			v:keypressed(const, scancode)
		end
	end
end
---------------
------END------
---------------

---------------
----GENERAL-------------------------------------------------------------------------------------------------------------------------
---FUNCTIONS------------------------------------------------------------------------------------------------------------------------
---------------
function entmanager:collide(_entid, altx, alty, altw, alth) -- Performs collision on a certain entity
	local worldCollision, X, Y, W, H= self.ents[_entid].worldcollision, altx or self.ents[_entid].x or 0, alty or self.ents[_entid].y or 0, altw or self.ents[_entid].w or 0, alth or self.ents[_entid].h or 0

	if worldCollision then -- do World Collision ( World is seperated from entities for clarity )
		local coll, block = world:collision(X, Y, W, H)
		if coll then
			return true , block, "block" -- if a collision with a block happened, return true with the id of the block collided with.
		end
	end
	for k,v in pairs(self.ents) do
		if v.collision and v.generalid~=_entid then
			local coll = collision.rec_rec(v.x, v.y, v.w, v.h, X, Y, W, H) -- check the collision between two rectangles
			if coll then
				return true, v.generalid, "entity" -- if collision happens, return true with the id of the entity collided with.
			end
		end
	end
	return false
end
---------------
------END------
---------------
---------------

--
return entmanager
