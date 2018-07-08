--
--> Setup & Loading ----------------------------------------------------------------------------------------------------------------
--

math.randomseed(math.random(9999,99999)+os.time()*math.sin(os.time()))

__GAME_VERSION = "0.0.0.0"

function love.load()	
	width, height	= love.graphics.getDimensions()		-- Width and Height
	mousex,mousey	= love.mouse.getPosition()				-- Get the position of the mouse

	--[[
	mathutils	= require "apis/mathutils"	-- math		utilities library
	vector		= require "apis/vector"			-- vector	utilities library
	tableutils	= require "apis/tableutils"	-- table	utilities library
	colorutils	= require "apis/colorutils"	-- color	utilities library
	collision	= require "apis/collision"	-- collision library

	background	=	require "background"			-- Background to render in the menu
	
	world 		= require "world" 					-- world library
	entmanager	= require "entities"				-- entmanager library
	mapeditor	=	require "mapeditor"				-- this is the map editor.

	menu		= require "menu"						-- this is the startup menu.
	gamemanager = require "gamemanager"			-- this is the game manager.
	audiomanager= require "audiomanager"		-- this is the audio manager.

	
	generalbackgroundcolor = colorutils:neww(128,128,128,255)
	
	entmanager:load() -- load the entities

	game_is_focused = true
	]]--
	--[[
	local main_tiles = love.graphics.newImage("images/hyptosis_tile-art-batch-1.png");
	
	local quads = {}
	for quadx = 0, math.floor(main_tiles:getWidth()/32)-1 do
		quads[quadx] = {}
		for quady = 0, math.floor(main_tiles:getHeight()/32)-1 do
			quads[quadx][quady] = love.graphics.newQuad(quadx*32, quady*32, 32, 32, main_tiles:getDimensions());
		end
	end
	sprite_batch = love.graphics.newSpriteBatch(main_tiles);
	
	for x=0,math.floor(width/32) do
		for y=0,math.floor(height/32) do
			sprite_batch:add(quads[x][y], x*32, y*32);
		end
	end]]--
	
	colorutils	= require "apis/colorutils"			-- Get the colorutils library
	ssmanager	= require "spritesheetmanager"		-- Get the sprite sheet manager library

	
	camera 		= require "camera"					-- The camera library
	maploader 	= require "maploader"				-- The map loader (mainly used by the world module)
	entmanager	= require "entities"				-- Entmanager library for managing entities
	world 		= require "world"					-- World module

	entmanager:load() -- Make sure to make the entity manager initialize
	
	world:setmap("maps/test map.lua"); -- The world will, for this test, add the player automatically
	--map = maploader.loadmap("maps/test map.lua")
	
	
end

--
--> Game events --------------------------------------------------------------------------------------------------------------------
--

function love.draw()
	love.window.setTitle(love.timer.getFPS());

	--> Background
	--< End Background

	--> World
	camera:set()

	world:draw_background()
	entmanager:draw()
	world:draw_foreground()

	camera:unset()
	--< End World
	love.graphics.print("hello", 100, 200);
end

function love.update(dt)
	mousex,mousey	= love.mouse.getPosition()				-- Update the position of the mouse ( in any circumstances )
	--[[
	gamemanager:update(dt)													-- Update using the gamemanager ( update depending on the state )
	]]--
	if love.keyboard.isDown("i") then
		camera:rotate(-math.pi/3 * dt);
	elseif love.keyboard.isScancodeDown("o") then
		camera:rotate(math.pi/3 * dt);
	end

	ssmanager:update(dt)
	entmanager:update(dt)
	camera:update(dt)
end

function love.keypressed(const, scancode, isrepeat)
	--[[
	gamemanager:keypressed(const, scancode, isrepeat)
	]]--
end

function love.keyreleased(const, scancode, isrepeat)
	--[[
	gamemanager:keyreleased(const, scancode, isrepeat)
	]]--

end

function love.mousepressed(x, y, button, istouch)
	--[[
	gamemanager:mousepressed(x, y, button, istouch)
	]]--
end

function love.mousereleased(x, y, button, istouch)
	--[[
	gamemanager:mousereleased(x, y, button, istouch)
	]]--
end

function love.textinput( text )
	--[[
	gamemanager:textinput(text)
	]]--
end

function love.filedropped(file)
	--[[
	if gamemanager.state == 2 then
		mapeditor:loadmap(nil, file)
	elseif gamemanager.state == 0 then
		mapeditor:loadmap(nil , file)
		mapeditor:savemap(file:getFilename():match(".+[%\\%/](.+)%."))
		menu:resetmapsshowing()
	end
	]]--
end

function love.focus(f)
	--[[
	game_is_focused = f
	]]--
end