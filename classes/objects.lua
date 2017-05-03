require( "classes.anims" );
local bit = require( "bit" )

object = { name = "Object", desc = "An object.", opaque = false };
function object.new( n, d, o )
	local o = { name = n, desc = d, opaque = o };
	setmetatable( o, { __index = object } )
	return o;
end

AIRLOCK_CLOSED, AIRLOCK_OPEN, AIRLOCK_OPENING, AIRLOCK_CLOSING, AIRLOCK_BOLTED, AIRLOCK_WELDED = 1, 2, 4, 8, 16, 32; --enums!
 --	 00001		 00010		 00100		01000			 10000
airlock = { name = "Airlock", desc = "An airlock.", opaque = true, state = AIRLOCK_CLOSED, time = 0, opentime = 5 };
air_sprites = { openanim = anim.new( .5, "resc/dooropening.png", 64, 64), closeanim = anim.new(1, "resc/doorclosing.png", 64, 64), airopen = love.graphics.newImage("resc/dooropen.png"), airclosed = love.graphics.newImage("resc/doorclosed.png" ) };
setmetatable( airlock, { __index = object } ); --airlock inherits from object: object/airlock
function airlock.new( n, d, t )
	local o = { name = n, desc = d, opaque = true, opentime = t, state = AIRLOCK_CLOSED };
	setmetatable( o, { __index = airlock } )
	return o;
end
function airlock.open( self, m, x, y )
	if bit.band( self.state, AIRLOCK_BOLTED ) == 0 then
		self.state = AIRLOCK_OPENING;
		self.opaque = false;
		self.time = os.clock();
		m:updateAtmos( x, y );
	end
end
function airlock.close( self, m, x, y )
	if bit.band( self.state, AIRLOCK_BOLTED ) == 0 then
		self.state = AIRLOCK_CLOSING
		self.opaque = true;
		self.time = os.clock();
		m:updateAtmos( x, y );
	end
end

function airlock.update( self, m, x, y )
	if bit.band( self.state, AIRLOCK_OPENING ) ~= 0 then
		if os.clock() >= self.time + air_sprites.openanim.length then
			self.state = AIRLOCK_OPEN;
			self.time = os.clock();
		end
	end
	if bit.band( self.state, AIRLOCK_OPEN ) ~= 0 then
		if os.clock() >= self.time + self.opentime then
			self:close( m, x, y );
		end
	end
	if bit.band( self.state, AIRLOCK_CLOSING ) ~= 0 then
		if os.clock() >= self.time + air_sprites.closeanim.length then
			self.state = AIRLOCK_CLOSE;
			self.time = os.clock();
		end
	end
end

function airlock.draw( self, x, y )
	if bit.band( self.state, AIRLOCK_OPENING ) ~= 0 then
		air_sprites.openanim:draw( x, y, os.clock() - self.time );
	elseif bit.band( self.state, AIRLOCK_CLOSING ) ~= 0 then
		air_sprites.closeanim:draw( x, y, os.clock() - self.time );
	elseif bit.band( self.state, AIRLOCK_CLOSED ) ~= 0 then
		love.graphics.draw( air_sprites.airclosed, x, y );
	elseif bit.band( self.state, AIRLOCK_OPEN ) ~= 0 then
		love.graphics.draw( air_sprites.airopen, x, y );
	end
end