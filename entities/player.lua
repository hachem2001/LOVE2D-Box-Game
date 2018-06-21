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
local world = require "world" -- gain access to the world in order to be able to call it's functions

player.w, player.h, player.x, player.y = 80,80, 32, 32;
player.currcolor = colorutils:neww(123,123,188,255);
player.collision = true -- Used to enable collision

player.iscontrolled = true -- To be updated later
player.movementspeed = 100 -- speed of movement

--player.direction = vector:new(1,0)^1 -- the ^1 normalizes the vector.

function player:setinfo(tbl) -- sets the info, self explanatory
	player.x, player.y = tbl.x or player.x, tbl.y or player.y;
	player.w, player.h = tbl.w or player.w, tbl.h or player.h;

	player.movementspeed = 100*self.w/32;
end

local sign = mathutils.sign
--
--> GENERAL STUFF ------------------------------------------------------------------------------------------------------------------
--
function player:draw() -- Draw the player
	love.graphics.push()

		love.graphics.setColor(self.color)
		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h) -- draw the player

	love.graphics.pop()
end

function player:update(dt) -- Update the player info
	self:updatepos(dt)
	player:checkgoalreached()
	if self.iscontrolled then -- If the player is controllable
		local mx, my = 0;
		if love.keyboard.isDown("right") then -- movement detection
			mx = self.movementspeed*dt
		elseif love.keyboard.isDown("left") then
			mx = -self.movementspeed*dt
		end
		if love.keyboard.isDown("up") then
			my = self.movementspeed*dt
		elseif love.keyboard.isDown("down") then
			my = -self.movementspeed*dt
		end
		self:move(mx, my);
	end
end

--
--> EVENTS AND MOVEMENT ------------------------------------------------------------------------------------------------------------
--

player.eventsneeded = {keypressed = false} -- currently no event is really needed
function player:keypressed(key, scancode, isrepeat) -- Checks if a key is pressed. not needed atm

end

function player:move(x, y) -- moves the player by x and y, checks collision and sees if the movement is possible
	self.x, self.y = self.x+x, self.y+y
	if self.collision then
		-- in our case AABB collision is used, so no need for checking, rather it'll be left for the world to simply make the collision work
		local results = {world:collide(self)} -- note : the player's table is passed because the x and y will be automatically changed by the function.
		-- This is possible because tables are passed by reference.
		if results[1] == true then
			print("Collision happened!") -- Just to test the return for now
		end
	end
end

return player
