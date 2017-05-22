function love.load()
	math.randomseed( os.time() );
	love.window.setMode( 1024, 768 )
	love.window.setTitle( "LÖVEstation 13" )
	require( "classes.map" );
	require( "classes.tile" );
	require( "classes.gas" );
	require( "classes.mob" );
	require( "classes.objects" );
	require( "classes.anims" );
	world = map.new( 10, 10 );
	world:randomMap();
	
	width, height = love.window.getMode();
	
	camera = { x = 0, y = 0, xf = 0, yf = 0 }
	
	mobs = { human.new( "Player" ) }
	
	updateUntilDone = {};
	
	buildtype = 2;
end

function handleAtmos(x,y,t)
	local res, ti;
	if not t then
		res = world:updateAtmos( map.toGrid( x, y, 64 ) );
	else
		res = world:updateAtmos( x, y );
	end
	if res then
		for a, xv in pairs( world.spaces ) do
			for b,yv in pairs( xv ) do
				table.insert(updateUntilDone,{x=a,y=b}); -- update atmos until no more air
			end
		end
	end
end

function love.update( dt )
	-- fps = math.ceil( 1/( dt ) );
	for k, v in ipairs( mobs ) do
		if not v or v.health <= 0 then
			table.remove( mobs, k );
		else
			v:update( world, dt );
		end
	end
	if mobs[1] then
		camera.x, camera.y = mobs[1].x - ( width / 2 + 64 ) / 64, mobs[1].y - (height / 2 + 64 ) / 64;
	end
	
	for k, v in ipairs( updateUntilDone ) do
		for j, u in ipairs( world.wmap[v.x][v.y].contents ) do
			local val;
			if u.opentime then
				val = u:update( world, v.x, v.y );
			else
				val = world:update();
			end
			if val then
				table.remove( updateUntilDone, k );
			end
		end
		if world.wmap[v.x][v.y].tile.name == "Space" then
			if not world:updateAtmos(v.x,v.y,100) then
				table.remove( updateUntilDone, k );
			end
		end
	end
end

function love.keypressed( key )
	if key == "h" then
		for k, v in ipairs( mobs ) do
			if v then
				v:hurt( 10 );
			end
		end
	end
	if key == "j" then
		local x, y = 0, 0;
		repeat
			x, y = math.random( 1, world.width ), math.random(1, world.height );
		until not world.wmap[x][y].tile.opaque
		table.insert( mobs, human.new( "Bob "..#mobs + 1, x, y, 100 ) )
	end
	local result = false;
	if not mobs[1] then
		if key == "w" then camera.y = camera.y - 1; elseif key == "s" then camera.y = camera.y + 1; end
		if key == "a" then camera.x = camera.x - 1; elseif key == "d" then camera.x = camera.x + 1; end
	else
		if key == "w" then result, x, y = mobs[1]:move( 0, -1, world ); mobs[1].dir = FACING_SOUTH; elseif key == "s" then result, x, y = mobs[1]:move(0, 1, world ); mobs[1].dir = FACING_NORTH; end
		if key == "a" then result, x, y = mobs[1]:move( -1, 0, world ); mobs[1].dir = FACING_WEST; elseif key == "d" then result, x, y = mobs[1]:move(1, 0, world ); mobs[1].dir = FACING_EAST; end
	end
	if key == "i" then
		if mobs[1] then
			handleAtmos( mobs[1].x, mobs[1].y, true );
		end
	end
	if result == "door" then
		table.insert( updateUntilDone, { x = x, y = y } );
		handleAtmos( x, y, true );
	end
	
	
	if key == "p" then
		local mx, my = love.mouse.getPosition();
		mx, my = mx + ( camera.x*64 ), my + (camera.y*64 );
		local tx, ty = map.toGrid( mx, my, 64 );
		table.insert(world.wmap[tx][ty].contents, airlock.new() );
	end
	local nums = {true, true, true, true, false, false, false, false, false, }
	nums[0] = false;
	if nums[tonumber( key )] then
		buildtype = tonumber( key );
	end
end

function build( t, x, y )
	x, y = x + ( camera.x*64 ), y + ( camera.y*64 );
	handleAtmos( x, y );
	world:setTile( t, x, y, 64 );
	handleAtmos( x, y );
end

function love.mousepressed( x, y, b, touch )
	-- x, y = x + ( camera.x*64 ), y + ( camera.y*64 );
	if not touch then
		if b == 1 then
			if buildtype < 4 then
				build( tiles[buildtype], x, y )
			else
				x, y = x + ( camera.x * 64 ), y + ( camera.y * 64 );
				local tx, ty = map.toGrid( x, y, 64 );
				world.wmap[tx][ty].tile.air.gases.Oxygen:add( 12.3149 );
			end
		elseif b == 2 then
			build( tiles[1], x, y )
		end
	end
end

function love.mousemoved( x, y, dx, dy, touch )
	-- x, y = x + ( camera.x*64 ), y + ( camera.y*64 );
	if not touch then
		if love.mouse.isDown( 1 ) then
			if buildtype < 4 then
				build( tiles[buildtype], x, y )
			end
		elseif love.mouse.isDown( 2 ) then
			build( tiles[1], x, y );
		end
	end
end

function love.draw()
	-- -[[
	love.graphics.setColor( 255, 255, 255 );
	local scale = 64
	love.graphics.translate( camera.x* - 64, camera.y* - 64 )
	world:render( 1 );

	-- love.graphics.print( fps );
	
	love.graphics.setColor( 255, 255, 255 );
	for k, v in ipairs( mobs ) do
		if v then
			v:draw( 64 );
		end
	end
	--[[
	love.graphics.setColor( 0, 255, 255 );
	if world.tmp then
		for k,v in pairs(world.tmp) do
			local x, y = map.fromGrid(v.x,v.y,64);
			love.graphics.rectangle( "line", x - 64, y - 64, 64, 64 );
		end
	end
	if world.spaces then
		for x, xv in pairs( world.spaces ) do
			for y, yv in pairs( xv ) do
				local x, y = map.fromGrid(x,y,64);
				love.graphics.rectangle( "fill", x - 64, y - 64, 64, 64 );
			end
		end
	end
	--]]
	
	love.graphics.translate( camera.x*64, camera.y*64 );
	
	if mobs[1] then
		love.graphics.print( mobs[1].health, 0, 0 );
	end
	if buildtype < 4 then
		love.graphics.print( tiles[buildtype].name, 0, 12 );
	end
	
	local mx, my = love.mouse.getPosition();
	love.graphics.setColor( 255, 255, 255 );
	local mtile = world:getTile( mx + ( camera.x*scale ), my + ( camera.y*scale ), scale );
	
	if mtile then
		love.graphics.print( string.format( "%s: %q, Oxygen: %.2f%%, Nitrogen: %.2f%%, Pressure: %.2f kPa", mtile.name, mtile.desc, ( mtile.air:getChemPressure( "Oxygen" )*100 ) / mtile.air.pressure, ( mtile.air:getChemPressure( "Nitrogen" )*100 ) / mtile.air.pressure, mtile.air.pressure ), mx, my );
		local dx, dy = world.toGrid( mx, my, scale )
		local _, wfrac = math.modf( ( width + 64 ) / 64 )
		local _, hfrac = math.modf( ( height + 64 ) / 64 )
		love.graphics.rectangle( "line", dx*scale - 64 - wfrac, dy*scale - 72 - hfrac, scale, scale );
	end
	-- ]]
end