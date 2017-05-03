require( "classes.tile" ); --for checking for space
require( "classes.objects" ); --open the airlock!!
local bit = require( "bit" ) --is it open?!?!?!

mob = { name = "Mob", x = 1, y = 1 }; --mob
function mob.new( n, x, y )
	local o = { name = n, x = x, y = y };
	setmetatable( o, { __index = mob } );
	return o;
end

carbon = { name = "Carbon", health = 100 };
setmetatable( carbon, { __index = mob } ); --I CAN INTO INHERITANCE! -- mob/carbon/
function carbon.new( n, x, y, h )
	local o = { name = n, x = x, y = y, health = h };
	setmetatable( o, { __index = carbon } );
	return o;
end

human = { img = love.graphics.newImage( "resc/human.png" ), dir = dir };
setmetatable( human, { __index = carbon } ); -- mob/carbon/human/
FACING_NORTH, FACING_EAST, FACING_SOUTH, FACING_WEST = 0, 1, 2, 3; --readability woo!!!
DRAW_NOR, DRAW_EST, DRAW_STH, DRAW_WST = love.graphics.newQuad( 0, 0, 64, 64, 256, 64), love.graphics.newQuad(63, 0, 64, 64, 256, 64), love.graphics.newQuad(127, 0, 64, 64, 256, 64), love.graphics.newQuad(191, 0, 64, 64, 256, 64 );
function human.new( n, x, y, h, img, dir )
	local o = { name = n, x = x, y = y, health = h, img = img, dir = dir };
	setmetatable( o, { __index = human } );
	return o;
end

function carbon.kill( self )
	
end

function carbon.hurt( self, amt )
	self.health = self.health - amt; -- healing is negative hurt
end

function carbon.move( self, x, y, m )
	if m:inBounds( self.x + x, self.y + y ) then
		local movetile = m.wmap[self.x + x][self.y + y];
		if movetile.tile then
			if not movetile.tile.opaque then
				for k, v in ipairs( movetile.contents ) do
					if v.name == "Airlock" and bit.band( v.state, AIRLOCK_CLOSED ) ~= 0 then
						v:open( m, self.x + x, self.y + y );
						return "door", self.x + x, self.y + y;
					end
					if v.opaque then
						return "blocked";
					end
				end
				self.x, self.y = self.x + x, self.y + y;
			end
		end
	end
end

function carbon.update( self, map, dt )
	self:live( map, dt );
end

function carbon.live( self, map, dt )
	if map.wmap[self.x][self.y].tile.air:getChemPressure( "Oxygen" ) <= 17 then --can't breathe in space, so you start dying!
		self:hurt( 10*dt );
	end
	self.health = math.floor( self.health );
	 -- if self.health <= 0 then self:kill(); end
end

function human.draw( self, scale )
	 -- love.graphics.draw( "human" );
	 -- love.graphics.setColor( 255*(1 - self.health/100), 255*(self.health/100), 0 );
	local activeQuad = DRAW_NOR;
	if self.dir == FACING_EAST then
		activeQuad = DRAW_EST;
	elseif self.dir == FACING_SOUTH then
		activeQuad = DRAW_STH;
	elseif self.dir == FACING_WEST then
		activeQuad = DRAW_WST;
	end
	love.graphics.draw( self.img, activeQuad, self.x*scale - scale, self.y*scale - scale );
	love.graphics.setColor( 255, 255, 255 );
	love.graphics.print( self.name, self.x*scale - scale/2, self.y*scale - scale/2 );
end