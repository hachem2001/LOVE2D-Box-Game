-- NOTE : ALL OTHER ENTITIES MUST INHERIT FROM THIS BASE ENTITY
local base = {}
base.eventsneeded = {} -- basically checks if an entity uses an event like keypressed or something and so uses it.

base._id = {base=entmanager.innerids.base}					-- v
entmanager.innerids.base=entmanager.innerids.base+1 -- Almost like an entity count calculator, for now though, it's useless

base.x = 0 -- Some info that might be needed in updating any entity
base.y = 0 -- ^
base.w = 0 -- ^
base.h = 0 -- ^

base.health = math.huge

-- INFO
function base:setinfo(...) -- ^ same as for x y w and h
	
end

-- HEALTH
function base:gethit(n) -- ^ same as for the last other
	base.health = base.health - n
	if base.health<=0 then
		base:selfdestruct()
	end
end

function base:selfdestruct() -- ^ same as for the last other
	
end

-- EVENTS

function base:draw() -- All entities must have a draw function
	
end

function base:update(dt) -- and All entities must be able to update
	
end

return base