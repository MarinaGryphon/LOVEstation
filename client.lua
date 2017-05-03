function handleData()
	repeat
		data, msg = udp:receive();
		if data then
			wrld, mbs = data:match("^([^;]*);([^;]*);");
			world, mobs = load(wrld), load(mbs); -- bad bad bad but i can't into network, CHANGE ASAP
		elseif msg ~= 'timeout' then 
			error("Network error: "..tostring(msg));
		end
	until not data;
end

function clientmove(x,y)
	
end

function love.load(t)
	math.randomseed(os.time());
	love.window.setMode(1024,768);
	love.window.setTitle("SS13");
	require("classes.map");
	require("classes.tile");
	--gas = require("classes.gas");
	require("classes.mob");
	require("classes.objects");
	require("classes.anims");
	
	local socket = require "socket";
	-- the address and port of the server
	local address, port = t[1] or "localhost",1234;

	world = map.new(30,30);
	
	width,height = love.window.getMode();
	
	camera = {x=0,y=0};
	
	queue = {};
	
	buildtype=2;
	
	udp.sendto
end

function love.update(dt)
	--fps = math.ceil(1/(dt));
	if mobs[1] then
		camera.x,camera.y = mobs[1].x-(width/2+64)/64,mobs[1].y-(height/2+64)/64;
	end
	
	for k,v in ipairs(updateUntilDone) do
		for j,u in ipairs(world.wmap[v.x][v.y].contents) do
			local val = u:update();
			if val then table.remove(updateUntilDone,k) end
		end
	end
	
	handleData();
end

function love.keypressed(key)
	if key=="h" then
		for k,v in ipairs(mobs) do
			if v then
				v:hurt(10);
			end
		end
	end
	if key=="j" then
		local x,y=0,0;
		repeat
			x,y=math.random(1,world.width),math.random(1,world.height);
		until not world.wmap[x][y].opaque
		table.insert(mobs,human.new("Bob "..#mobs+1,x,y,100))
	end
	local result = false;
	if not mobs[1] then
		if key=="w" then camera.y=camera.y-1; elseif key=="s" then camera.y=camera.y+1; end
		if key=="a" then camera.x=camera.x-1; elseif key=="d" then camera.x=camera.x+1; end
	else
		if key=="w" then result,x,y=mobs[1]:move(0,-1,world); mobs[1].dir=FACING_SOUTH; elseif key=="s" then result,x,y=mobs[1]:move(0,1,world); mobs[1].dir=FACING_NORTH; end
		if key=="a" then result,x,y=mobs[1]:move(-1,0,world); mobs[1].dir=FACING_WEST; elseif key=="d" then result,x,y=mobs[1]:move(1,0,world); mobs[1].dir=FACING_EAST; end
	end
	if result=="door" then
		table.insert(updateUntilDone,{x=x,y=y});
	end
	
	
	if key=="p" then
		local mx,my=love.mouse.getPosition();
		mx,my = mx + (camera.x*64), my + (camera.y*64);
		local tx,ty=map.toGrid(mx,my,64);
		table.insert(world.wmap[tx][ty].contents,airlock.new());
	end
	local nums={true,true,true,true,true,true,true,true,true}
	nums[0]=true;
	if nums[tonumber(key)] then
		buildtype=tonumber(key);
	end
end

function build(t,x,y)
	x,y = x + (camera.x*64), y + (camera.y*64);
	return string.format("world:setTile(%d,%d,%d,64)",t,x,y); -- digit digit digit!!
end

function love.mousepressed(x,y,b,touch)
	--x,y = x + (camera.x*64), y + (camera.y*64);
	if not touch then
		if b==1 then
			table.insert(queue,build(tiles[buildtype],x,y))
		elseif b==2 then
			table.insert(queue,build(tiles[1],x,y));
		end
	end
end

function love.mousemoved(x,y,dx,dy, touch)
	--x,y = x + (camera.x*64), y + (camera.y*64);
	if not touch then
		if love.mouse.isDown(1) then
			build(tiles[buildtype],x,y)
		elseif love.mouse.isDown(2) then
			build(tiles[1],x,y);
		end
	end
end

function love.draw()
	---[[
	local scale=64
	love.graphics.translate(camera.x*-64,camera.y*-64)
	world:render(1);

	--love.graphics.print(fps);
	
	love.graphics.setColor(255,255,255);
	for k,v in ipairs(mobs) do
		if v then
			v:draw(64);
		end
	end
	love.graphics.translate(camera.x*64,camera.y*64);
	
	
	
	
	
	if mobs[1] then
		love.graphics.print(mobs[1].health,0,0);
	end
	love.graphics.print(tiles[buildtype].name,0,12);
	
	local mx,my = love.mouse.getPosition();
	love.graphics.setColor(255,255,255);
	local mtile = world:getTile(mx+(camera.x*scale),my+(camera.y*scale),scale);
	
	if mtile then
		love.graphics.print(mtile.name..": "..mtile.desc,mx,my);
		local dx,dy=world.toGrid(mx,my,scale)
		local _,wfrac = math.modf((width+64 )/64)
		local _,hfrac = math.modf((height+64)/64)
		love.graphics.rectangle("line",dx*scale - 64 - wfrac,dy*scale-72-hfrac,scale,scale);
	end
	--]]
end