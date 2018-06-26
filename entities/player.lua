local player = entmanager:rawnew("base") -- Basically "INHERIT" what base.lua has

--[[-- NOTES :
	11/07/2017 :
	* The player now cannot stick to a ground if he's moving left of right in mid air, he can if the block is adjacent to another, or if he jumps ( jump switch).
	  - CHECK BOOKMARK 1 FOR LINE OF CHANGE ^

	02/07/2017 :
	* I re-enabled event keypressed so that whenever space is pressed switching gravity is disabled

	OLD :
	* I made the keypressed event disabled for the player because I entend to replace it with keyDown in the update section, (addition of multiple gravities)
	* for now player.switch_at_edges will stay false because I haven't figured out what went wrong.
--]]--

--local vector = require "apis/vector"
local world = world or error("World not loaded before the making of the player entitie") -- assure access to the world in order to be able to call it's functions
local camera = camera or error("Camera not loaded before the use of the player entitie") -- assure access to the camera

player.w, player.h, player.x, player.y = 32, 32, 32, 32;
player.color = colorutils:neww(123,123,188,255);
player.collision = true -- Used to enable collision

player.iscontrolled = true -- To be updated later
player.movementspeed = 32*3 -- speed of movement

--player.direction = vector:new(1,0)^1 -- the ^1 normalizes the vector.
--
--> SETUPS
--
ssmanager:add("player", 32, 32, 6, 3, "images/player/player.png") -- set up the animation of the player.

--
--> Functions
--

function player:setinfo(tbl) -- sets the info, self explanatory
	player.x, player.y = tbl.x or player.x, tbl.y or player.y;
	player.w, player.h = tbl.w or player.w, tbl.h or player.h;
end

--
--> GENERAL STUFF ------------------------------------------------------------------------------------------------------------------
--
function player:draw() -- Draw the player
	love.graphics.push()

		--[[ Old way of doing this
		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h) -- draw the player
		]]--
		--v animated way of doing this
		love.graphics.setColor(self.color)
		ssmanager:draw("player", self.x, self.y, self.w, self.h) -- the w and h are for now fixed
	love.graphics.pop()
end

function player:update(dt) -- Update the player info
	if self.iscontrolled then -- If the player is controllable
		local mx, my = 0, 0;
		if love.keyboard.isDown("right") then -- movement detection
			mx = self.movementspeed*dt
		elseif love.keyboard.isDown("left") then
			mx = -self.movementspeed*dt
		end
		if love.keyboard.isDown("down") then
			my = self.movementspeed*dt
		elseif love.keyboard.isDown("up") then
			my = -self.movementspeed*dt
		end
		self:move(mx, my);
	end
	camera:set_position(math.floor(self.x+self.w/2), math.floor(self.y+self.h/2))
end

--
--> EVENTS AND MOVEMENT ------------------------------------------------------------------------------------------------------------
--

player.eventsneeded = {keypressed = false} -- currently no event is really needed
function player:keypressed(key, scancode, isrepeat) -- Checks if a key is pressed. not needed atm

end

function player:move(x, y) -- moves the player by x and y, checks collision and sees if the movement is possible
	if self.collision then
		-- in our case AABB collision is used, so no need for checking, rather it'll be left for the world to simply make the collision work
		X_AL, Y_AL = world:collide(self, x, y)
		if not X_AL then
			self.x = self.x + x;
		end
		if not Y_AL then
			self.y = self.y + y;
		end
	end
end

return player
