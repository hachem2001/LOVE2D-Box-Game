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

player.w, player.h, player.x, player.y, player.currcolor = 80,80, 40, 40, colorutils:neww(123,123,188,255)
player.switchoncolor, player.switchoffcolor = colorutils:neww(123,123,188,255), colorutils:neww(188,123,123,255)

player.atground = false -- if the player is sitting on ground or not.
player.collision = true -- This means it uses collision
player.gravity = true -- This means it's affected by gravity
player.worldcollision = true
player.iscontrolled = true -- To be updated later


player.switch_at_edges	= false -- change gravity if you near a pitfall ( in any direciton ).
player.switchallowed		= true	-- If you can change gravity or not.
player.allowspaceswitch	=	true	-- Ff you can reset your switch allowance by space
player.movementspeed		= 100 -- speed of movement
player.jumpdistance			= 170 -- the distance that you want to jump. The velocity is recalculated later
player.jumpower					= world.gravity_y * math.sqrt(player.jumpdistance/world.gravity_y) -- jumpower


player.currverticalvel	= 0 -- current vertical velocity
player.currhorizontvel	= 0 -- current hozizontal velocity
player.verticalDir			= 1 -- This sets if you go down or up if you're in mid air. (direction)
player.horizontDir			= 0 -- This sets if you go right or left if you're in mid air. (direction)

player.jumpdelay, player.jumpstamp = 0.1, love.timer.getTime() -- delay before you can rejump again

function player:setinfo(tbl) -- sets the info, self explanatory
	player.x, player.y = tbl.x or player.x, tbl.y or player.y
	player.w, player.h = tbl.w or player.w, tbl.h or player.h

	player.switchoncolor = tbl.color1 or player.switchoncolor
	player.switchoffcolor= tbl.color2 or player.switchoffcolor

	player.jumpdistance			= tbl.jumpdistance or player.jumpdistance
	player.jumpower					= world.gravity_y * math.sqrt(player.jumpdistance/world.gravity_y) -- jumpower
	
	player.movementspeed = 100*self.w/42

	player.verticalDir, player.horizontDir = tbl.GY or player.verticalDir, tbl.GX or player.horizontDir
end

local sign = mathutils.sign
--
--> GENERAL STUFF ------------------------------------------------------------------------------------------------------------------
--
function player:draw() -- Draw the player
	love.graphics.push()
		love.graphics.setColor(self.switchallowed and self.switchoncolor or self.switchoffcolor)

		love.graphics.rectangle("fill", self.x, self.y, self.w, self.h) -- draw the player

--	love.graphics.print(tostring(self.verticalDir.."°"..self.currverticalvel.." | "..self.horizontDir.."°"..self.currhorizontvel), 50, 50) -- Some debug stuff
--	love.graphics.print("At ground : "..tostring(self.atground), 50, 100)
	love.graphics.pop()
end

function player:update(dt) -- Update the player info
	self:updatepos(dt)
	player:checkgoalreached()
	if self.iscontrolled then -- If the player is controllable
		local GX, GY = self.horizontDir, self.verticalDir
		if love.keyboard.isDown("right") then -- movement detection
			self:move(GY*self.movementspeed*dt, -GX*self.movementspeed*dt, dt)
		elseif love.keyboard.isDown("left") then
			self:move(-GY*self.movementspeed*dt, GX*self.movementspeed*dt, dt)
		end
		if love.keyboard.isDown("up") then
			self:jump(self.jumpower)
		end
	end
end

function player:checkgoalreached()
	if self.verticalDir == world.goal.GY and self.horizontDir==world.goal.GX and collision.rec_rec(self.x, self.y, self.w, self.h, world.goal.x+world.goal.w/4, world.goal.y+world.goal.h/4, world.goal.w/4, world.goal.h/4) then
		if gamemanager.state == 1 then
			menu.slide = 2
			gamemanager:setstate(0)
		elseif gamemanager.state == 3 then
			gamemanager:setstate(2)
		end
	end
end

--
--> EVENTS AND MOVEMENT ------------------------------------------------------------------------------------------------------------
--

player.eventsneeded = {keypressed = true} -- state that this entity uses keypressed event.
function player:keypressed(key, scancode, isrepeat) -- Checks if a key is pressed.
	if scancode == "space" and self.allowspaceswitch then
		self.switchallowed = not self.switchallowed
	elseif scancode == "r" then
		self.currverticalvel	= 0 -- current vertical velocity
		self.currhorizontvel	= 0 -- current hozizontal velocity
		self.x = world.playerspawn.x
		self.y = world.playerspawn.y
		self.w = world.playerspawn.w
		self.h = world.playerspawn.h
		self.verticalDir = world.playerspawn.GY -- This sets if you go down or up if you're in mid air. (direction)
		self.horizontDir = world.playerspawn.GX -- This sets if you go right or left if you're in mid air. (direction)
	end
end

function player:switchgravity(x, y)
	if self.switchallowed then
		if x>0 then -- If you go right gravity now becomes at right ( you're pulled to the right )
			self.verticalDir, self.horizontDir = 0, 1

		elseif x<0 then -- If you go left gravity now becomes at left ( you're pulled to the left )
			self.verticalDir, self.horizontDir = 0, -1

		elseif y>0 then -- If you go down gravity now becomes down ( you're pulled down )
			self.verticalDir, self.horizontDir = 1, 0

		elseif y<0 then -- If you go up gravity now becomes up ( you're pulled up )
			self.verticalDir, self.horizontDir = -1, 0

		end
		self.currverticalvel, self.currhorizontvel = 0, 0 -- reset vertical speeds
		audiomanager:play("switch")
	end
end

function player:move(x, y, dt) -- movement detection, checks collision and sees if the movement is possible
	local newx, newy = self.x+x, self.y+y
	if self.collision then
		local coll, b_id, typ = entmanager:collide(self.generalid, newx, newy, self.w,self.h)
		if coll then -- IF YOU COLLIDE
			-- checks if the typ is a block, and if it allows switching
			local blocktype = world.blocks[b_id].typ -- blocktype 1 means unswitcheable ( green ).
			if self.atground and typ=="block" and blocktype==0 then -- Bookmark 1 : Don't change gravity direction if the player is in mid air moving, change gravity if the player is on ground moving
				self:switchgravity(x, y)
			end
		else -- if no collision happens
			self.x, self.y = newx, newy -- Keeps on moving
		end
	end
end

function player:simulategravity(AX, AY, dt)
	local mcurrverticalvel = self.currverticalvel + self.verticalDir * world.gravity_y * dt
	local mcurrhorizontvel = self.currhorizontvel + self.horizontDir * world.gravity_x * dt

	local newx, newy = AX + mcurrverticalvel*dt, AY + mcurrhorizontvel*dt
	return newx, newy, entmanager:collide(self.generalid, newx, newy, self.w, self.h)
end


function player:updatepos(dt) -- update the pos with the velocity and such
	self.currverticalvel = self.currverticalvel + self.verticalDir * world.gravity_y * dt -- we add vertical velicity with respect to direction. If the direction is 1 the player goes downward when the game updates ( down gravity )
	self.currhorizontvel = self.currhorizontvel + self.horizontDir * world.gravity_x * dt -- we add horizontal velicity with respect to direction. If the direction is 1 the player goes right when the game updates ( right gravity )

	if self.collision then
		local newx, newy = self.x + self.currhorizontvel*dt, self.y + self.currverticalvel*dt -- we recalculate the new positions
		if self.horizontDir~=0 then -- if it's moving right or left then do this
			local collx, b_id, typ = entmanager:collide(self.generalid, newx, self.y, self.w, self.h) -- checks collision
			if collx then  -- if collision happens
				local block, blocktype = world.blocks[b_id], world.blocks[b_id].typ
				if self.switchallowed and sign(self.currhorizontvel)==-self.horizontDir and typ=="block" and blocktype == 0 then -- if you jump and while jumping you meet a wall, now gravity switches from left to right or from right to left
					self.horizontDir = -self.horizontDir
					audiomanager:play("switch")
				elseif sign(self.currhorizontvel) == self.horizontDir and typ == "block" and blocktype==2 and self.y+self.h/2<block.y+block.h and self.y+self.h/2>block.y then -- if you're falling in the direction of gravity and you touch the special reverse gravity block it will reverse it.
					self.horizontDir = -self.horizontDir
					audiomanager:play("switch")
				end
				self.currhorizontvel = 0 -- reset the horizontal speed
			else
				self.x = newx
			end
		end
		if self.verticalDir~=0 then -- if it's moving up or down do this
			local colly, b_id, typ = entmanager:collide(self.generalid, self.x, newy, self.w, self.h) -- checks collision
			if colly then -- if collision happens
				local block, blocktype = world.blocks[b_id], world.blocks[b_id].typ
				if self.switchallowed and sign(self.currverticalvel)==-self.verticalDir and typ=="block" and blocktype==0 then -- if you jump and while jumping you meet a wall, now gravity switches from up to down or from down to up
					self.verticalDir = -self.verticalDir
					audiomanager:play("switch")
				elseif sign(self.currverticalvel) == self.verticalDir and typ == "block" and blocktype==2 and self.x+self.w/2<block.x+block.w and self.x+self.w/2>block.x then -- if you're falling in the direction of gravity and you touch the special reverse gravity block it will reverse it.
					self.verticalDir = -self.verticalDir
					audiomanager:play("switch")
				end
				self.currverticalvel = 0
			else
				self.y = newy
			end
		end
		if (self.verticalDir~=0 and self.currverticalvel==0)or(self.horizontDir~=0 and self.currhorizontvel==0) then -- Checks when we are currently at the ground.
			self.atground = true
		else
			self.atground = false
		end
	end
end

function player:jump(jumpower) -- Performs a jump ( adding upwards velocity )
	local t = love.timer.getTime()
	if self.atground and t>=self.jumpdelay+self.jumpstamp then
		self.currverticalvel = -self.verticalDir * jumpower -- negative because it's going the opposite way
		self.currhorizontvel = -self.horizontDir * jumpower -- same thing for x.
		self.jumpstamp = t

		audiomanager:play("jump")
	end
end

return player
