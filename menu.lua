local menu	=	{}
--

--[[-- Notes
	* boxes callback MUST be a function. for example menu.boxes:new(50, 50, 100, 50, "Quit", function()love.event.quit()end)
--]]--
menu.__gui_paths = {
	scroll = "gui/slider.lua",
	levelselector = "gui/levelselector.lua",
}
menu.gui_elements = {}

--
--> PRESETUP : BOXES ---------------------------------------------------------------------------------------------------------------
--

-- ->boxmanager and scrollmanager setup
menu.slide = 0 -- which slide to show and run.
menu.boxmanager = {}
menu.boxmanager.boxes = {}

menu.scrollmanager = {}
menu.scrollmanager.scrolls = {}

menu.guiaddons = {}
menu.guiaddons.elements = {}
function menu:load()
	for k,v in pairs(self.__gui_paths) do
		self.gui_elements[k] = love.filesystem.load(v)
	end
end

function menu.boxmanager:new(slide, x, y, w, h, text, callback, info)
	self.boxes[#self.boxes+1] = {slide = slide, x=x, y=y, w=w, h=h, text=love.graphics.newText(menu.font, text), callback=callback, actioned=false, insidecolor=colorutils:neww(), outlinecolor = colorutils:neww(), textcolor = colorutils:neww(), info = info}
end

function menu.scrollmanager:new(slide, x, y, w, h, text, image, info)
	local m = menu.gui_elements["scroll"]()
	m.slide = slide
	m:set_position(x, y)
	m:set_dimensions(w, h)
	m:set_text(text)
	self.scrolls[#self.scrolls+1] = m
	return #self.scrolls
end

function menu.guiaddons:new(slide, typ)
	local m = menu.gui_elements[typ]()
	m.slide = slide
	self.elements[#self.elements+1] = m
	return #self.elements
end
-- ->end boxmanager and scrollmanager setup

-- ->boxmanager events
function menu:drawbox(box)
	love.graphics.push()
		love.graphics.setColor(box.insidecolor)
		love.graphics.rectangle("fill", box.x, box.y, box.w, box.h, 5)
		love.graphics.setColor(box.outlinecolor)
		love.graphics.rectangle("fill", box.x, box.y, box.w, box.h, 5)
		love.graphics.setColor(box.textcolor)
		love.graphics.draw(box.text, math.floor(box.x+box.w/2-box.text:getWidth()/2), math.floor(box.y+box.h/2-box.text:getHeight()/2))
	love.graphics.pop()
end
-- -> end boxmanager events

--
--> THE MENU -----------------------------------------------------------------------------------------------------------------------
--
menu.font = love.graphics.getFont()
menu.colors	=	{
	background1						= colorutils:neww(80	,	50	,	80	,	255	),
	background2 					= colorutils:neww(100	,	100	,	200	,	255	),

	boxes	=	{
		insideU							=	colorutils:neww(255	,	255	,	255	,	255 ),
		outlineU						=	colorutils:neww(255	,	255	,	255	,	255	),
		textU								= colorutils:neww(255	,	255	,	255	,	255	),

		inside1							=	colorutils:neww(70		,	90	,	160	,	140 ),
		outline1						=	colorutils:neww(150	,	150	,	160	,	250	),
		text1								= colorutils:neww(255	,	255	,	255	,	255	),

		inside2							=	colorutils:neww(90		,	70	,	140	,	150 ),
		outline2						=	colorutils:neww(70		,	90	,	160	,	240	),
		text2								= colorutils:neww(180	,	180	,	180	,	255	),

		inside_actioned			= colorutils:neww(200	,	80	,	90	,	180	),
		outline_actioned		= colorutils:neww(200	,	80	,	90	,	255	),
		text_actioned				= colorutils:neww(255	,	255	,	255	,	255	),

	},
}


function menu:draw()
	love.graphics.push()
		for k,v in pairs(self.boxmanager.boxes) do
			if v.slide == self.slide then
				self:drawbox(v)
			end
		end
		for k,v in pairs(self.scrollmanager.scrolls) do
			if v.slide == self.slide then
				v:draw()
			end
		end
		for k,v in pairs(self.guiaddons.elements) do
			if v.slide == self.slide then
				v:draw()
			end
		end
	love.graphics.pop()
end

function menu:update(dt)
	local dtt = dt*4
	if game_is_focused then
		generalbackgroundcolor = generalbackgroundcolor(self.colors.background1, 2*dtt)
		for k,v in pairs(self.boxmanager.boxes) do
			if v.slide == self.slide then
				if v.actioned then
					v.insidecolor		= v.insidecolor(self.colors.boxes.inside_actioned, 2*dtt)
					v.outlinecolor	= v.outlinecolor(self.colors.boxes.outline_actioned, 2*dtt)
					v.textcolor			= v.textcolor(self.colors.boxes.text_actioned, 2*dtt)
				elseif collision.point_rec(mousex, mousey, v.x, v.y, v.w, v.h) then
					v.insidecolor		= v.insidecolor(self.colors.boxes.inside2, dtt)
					v.outlinecolor	= v.outlinecolor(self.colors.boxes.outline2, dtt)
					v.textcolor			= v.textcolor(self.colors.boxes.text2, dtt)
				else
					v.insidecolor		= v.insidecolor(self.colors.boxes.inside1, dtt)
					v.outlinecolor	= v.outlinecolor(self.colors.boxes.outline1, dtt)
					v.textcolor			= v.textcolor(self.colors.boxes.text1, dtt)
				end
			end
		end
		for k,v in pairs(self.scrollmanager.scrolls) do
			if v.slide == self.slide then
				v:update(dtt)
			end
		end
		for k,v in pairs(self.guiaddons.elements) do
			if v.slide == self.slide then
				v:update(dt)
			end
		end
	end
end

function menu:mousepressed(x, y, button, istouch)
	for k,v in pairs(self.guiaddons.elements) do
		if v.slide == self.slide then
			v:mousepressed(x, y, button, istouch)
		end
	end
	for k,v in pairs(self.boxmanager.boxes) do
		if v.slide == self.slide then
			local coll = collision.point_rec(x, y, v.x, v.y, v.w, v.h)
			if coll then
				self.boxmanager.boxes[k].actioned = true
				break;
			end
		end
	end
	for k,v in pairs(self.scrollmanager.scrolls) do
		if v.slide == self.slide then
			v:mousepressed(x, y, button, istouch)
		end
	end
end

function menu:mousereleased(x, y, button, istouch)
	for k,v in pairs(self.guiaddons.elements) do
		if v.slide == self.slide then
			v:mousereleased(x, y, button, istouch)
		end
	end
	for k,v in pairs(self.boxmanager.boxes) do
		if v.slide == self.slide then
			local coll = collision.point_rec(x, y, v.x, v.y, v.w, v.h)
			if coll and v.actioned then
				v:callback()
				audiomanager:play("clickout")
				self.boxmanager.boxes[k].actioned = false
				break
			end
		end
	end
	for k,v in pairs(self.boxmanager.boxes) do
		v.actioned = false
	end
	for k,v in pairs(self.scrollmanager.scrolls) do
		if v.slide == self.slide then
			v:mousereleased(x, y, button, istouch)
		end
	end
end

function menu:keypressed(key, scancode, isrepeat)
	for k,v in pairs(self.guiaddons.elements) do
		if v.slide == self.slide then
			v:keypressed(key, scancode, isrepeat)
		end
	end
end

function menu:keyreleased(key, scancode, isrepeat)
	for k,v in pairs(self.guiaddons.elements) do
		if v.slide == self.slide then
			v:keyreleased(key, scancode, isrepeat)
		end
	end
end

--
--> The interface ------------------------------------------------------------------------------------------------------------------
--

menu:load()
--slide0
menu.boxmanager:new(0, 50,	50		,		200,	50, "Continue", function() gamemanager:setstate(1) world:loadmap("main maps/basic 1.txt") end)
menu.boxmanager:new(0, 50,	120		,		200,	50, "Choose Map", function() menu.slide = 1 end)
menu.boxmanager:new(0, 50,	190		,		200,	50, "Map Editor", function() mapeditor.currsavename= nil; gamemanager:setstate(2) end)
menu.boxmanager:new(0, 50,	260		,		200,	50, "Settings", function() menu.slide = 5 end)
menu.boxmanager:new(0, 50,	330		,		200,	50, "About", function() menu.slide = 6 end)
menu.boxmanager:new(0, 50,	400		,		200,	50, "Quit", function() love.event.quit() end)

--slide1
menu.boxmanager:new(1, 50,	50		,		200,	50, "Main maps", function() menu.slide = 3 end)
menu.boxmanager:new(1, 50,	120		,		200,	50, "External maps", function() menu.slide = 4 end)
menu.boxmanager:new(1, 50,	190		,		200,	50, "External maps folder:\n"..savedirectory, function() love.system.openURL(savedirectory) end)
menu.boxmanager:new(1, width-150,	height-70		,		100,	50,	"Back", function() menu.slide = 0 end)

--slide2
menu.boxmanager:new(2, width/2-50, height/2-25, 100, 50, "YOU WON", function()end)
menu.boxmanager:new(2,	width-150, height-70, 100, 50, "Back", function() menu.slide = 1 end)

--slide6
menu.scrollmanager:new(6, 50, 50, width-150, height-150, [[This game was developped with LÖVE, also known as Love2d (https://love2d.org)

The game code is written by Yimo Awanardo

The sounds were made by : (didn't ask them if I can say their name)

Most game libraries where made by Yimo Awanardo, and they are :
• collision.lua ° collision library
• colorutils.lua ° color library:color shifting & other stuff.
• mathutils.lua ° math library for extra
• tableutils.lua ° table library
• utigo.lua ° geometry library (point intersection, ...)
• vector.lua ° vector library (for vector handling)]])
menu.boxmanager:new(6,	width-150, height-70, 100, 50, "Back", function() menu.slide = 0 end)

--slide5
menu.boxmanager:new(5, 50,	50			,		200,	50, "Sounds : on", function(self)
		self.info=not self.info;
		self.text = love.graphics.newText(menu.font, self.info and "Sounds : on" or "Sounds : off");
		audiomanager.playsounds = self.info;
		end,
		true)
menu.boxmanager:new(5,	width-150, height-70, 100, 50, "Back", function() menu.slide = 0 end)


--
return menu
