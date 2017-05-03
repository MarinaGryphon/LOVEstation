require( "classes.gas" );
tile = { name = "Space", desc = "Space!", opaque = false, img = love.graphics.newImage( "resc/space.png"), air = air.new( ) };

function tile.new( n, d, o, i, a )
	local o = { name = n, desc = d, opaque = o, img = i, air = a };
	setmetatable( o, { __index = tile } )
	return o;
end

function tile.draw( self, x, y, scale )
	love.graphics.draw( self.img, x*scale - scale, y*scale - scale, 0, scale/64, scale/64 );
end

function tile.dup( self )
	local o = {};
	setmetatable( o, { __index = self } );
	return o;
end

tiles = {};
tiles[1] = tile.new( _, _, _, _, air.new( { gas.new( chems[1], 0, 0, 0 ), gas.new( chems[2], 0, 0, 0 ), gas.new( chems[3], 0, 0, 0 ), gas.new( chems[4], 0, 0, 0 ) } ) ); --space has no air!
tiles[2] = tile.new( "Plating", "A square meter of plating.", false, love.graphics.newImage("resc/plating.png") );
tiles[3] = tile.new( "Wall", "A big steel wall.", true, love.graphics.newImage("resc/wall.png") );