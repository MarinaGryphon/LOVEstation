local socket = require "socket";
local udp = socket.udp();
udp:settimeout(0);
udp:setsockname('*', 1234);
local data, msg_or_ip, port_or_nil;

math.randomseed(os.time());
require("classes.map");
require("classes.tile");
--gas = require("classes.gas");
require("classes.mob");
require("classes.objects");
require("classes.anims");
world = map.new(30,30);
world:randomMap();

local server = {};
server.time = os.time();
server.lastupdate = os.time();
server.status = true;
server.tickrate = 0.33;

local connections = {};
local protid = string.char(60,70,64,68);

while running do
	local oldtime = server.time;
	server.time = os.time();
	local dt = (server.time - oldtime);
	
	
	data, msg_or_ip, port_or_nil = udp:receivefrom()
	if data then
		-- more of these funky match paterns!
		if data:sub(1,4)==protid then
			data = data:sub(5,-1);
			entity, cmd, parms = data:match("^(%S*) (%S*) (.*)")
			if cmd == 'move' then
				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
				assert(x and y) -- validation is better, but asserts will serve.
				x, y = tonumber(x), tonumber(y)
				-- and finally we stash it away
				local ent = world[entity] or {x=0,y=0};
				world[entity] = {x=ent.x+x, y=ent.y+y}
			elseif cmd == 'at' then
				local x, y = parms:match("^(%-?[%d.e]*) (%-?[%d.e]*)$")
				assert(x and y) -- validation is better, but asserts will serve.
				x, y = tonumber(x), tonumber(y)
				world[entity].x,world[entity].y=x,y;
			elseif cmd == 'update' then
				for k, v in pairs(world) do
					v.y=v.y+40*dt;
					udp:sendto(string.format("%s %s %d %d", k, 'at', v.x, v.y), msg_or_ip,  port_or_nil)
				end
			elseif cmd == 'quit' then
				running = false;
			else
				print("unrecognised command:", cmd)
			end
			print(data);
		end
	elseif msg_or_ip ~= 'timeout' then
		error("Unknown network error: "..tostring(msg))
	end
	
	
	
	for k,v in ipairs(mobs) do
		if not v then
			table.remove(mobs,k);
			break;
		end
		if v then
			mobs[k]=v:update(world,dt);
		end
	end
	
	if oldtime - lastupdate > server.tickrate then
		server.lastupdate = os.time();
		--udp.sendto
	end
	socket.sleep(0.05);
end